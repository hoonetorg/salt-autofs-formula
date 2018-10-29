# vim: sts=2 ts=2 sw=2 et ai
{% from "autofs/map.jinja" import autofs with context %}

autofs__pkg_autofs:
  pkg.installed:
    - name: autofs
{% if autofs.slsrequires is defined and autofs.slsrequires %}
    - require:
{% for slsrequire in autofs.slsrequires %}
      - {{slsrequire}}
{% endfor %}
{% endif %}
    - pkgs: {{autofs.autofspackages}}

autofs__file_/etc/auto.master.d:
  file.directory:
    - name: /etc/auto.master.d
    - user: root
    - group: root
    - mode: 0755
    - require:
      - pkg: autofs__pkg_autofs
    - watch_in:
      - service: autofs__service_autofs


autofs__file_/etc/auto.master:
  file.managed:
    - name: /etc/auto.master
    - user: root
    - group: root
    - mode: 0644
    - contents: "+dir:/etc/auto.master.d"
    - contents_newline: True
    - require:
      - pkg: autofs__pkg_autofs
      - file: autofs__file_/etc/auto.master.d
    - watch_in:
      - service: autofs__service_autofs


{% if autofs.maps is defined and autofs.maps %}
{% for autofsmap, autofsmap_data in autofs.maps.items() %}
autofs__file_/etc/auto.master.d/{{autofsmap}}.autofs:
  file.managed:
    - name: /etc/auto.master.d/{{autofsmap}}.autofs
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - contents: "{{autofsmap_data.mount}} /etc/auto.{{autofsmap}}  {{autofsmap_data.opts|default('')}}"
    - contents_newline: True
    - require:
      - pkg: autofs__pkg_autofs
      - file: autofs__file_/etc/auto.master
      - file: autofs__file_/etc/auto.master.d
    - watch_in:
      - service: autofs__service_autofs

autofs__file_/etc/auto.{{autofsmap}}:
  file.managed:
    - name: /etc/auto.{{autofsmap}}
    - replace: False
    - user: root
    - group: root
    - mode: 0644

{% for entity, entity_data in autofsmap_data.entities.items() %}

{%- set options = entity_data.get('options', '') %}
{%- set destination = entity_data.get('destination', entity) %}

autofs__file_/etc/auto.{{autofsmap}}_{{entity}}:
  file.replace:
    - name: /etc/auto.{{autofsmap}}
    - pattern: ^\s*{{destination}}\s+.*$
    - repl: "{{destination}} {{options}}  {{entity_data.source}}"
    - count: 1
    - append_if_not_found: True
    - require:
      - pkg: autofs__pkg_autofs
      - file: autofs__file_/etc/auto.{{autofsmap}}
      - file: autofs__file_/etc/auto.master
      - file: autofs__file_/etc/auto.master.d
    - watch_in:
      - service: autofs__service_autofs
{% endfor %}
{% endfor %}
{% endif %}

autofs__service_autofs:
  service.running:
    - name: autofs
    - reload: True
    - enable: true
    - require:
      - pkg: autofs__pkg_autofs
