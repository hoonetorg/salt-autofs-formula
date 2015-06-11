# salt-autofs-formula
Install and configure autofs (currently only tested on CentOS 7.1)

The file pillar.example shows an example how to configure direct maps.

The file pillar.example.outcome shows the resulting files on the minion
after a successful run of the autofs-formula with the pillar data.


It should be easy to implement indirect maps or anything else with it.

Also it should be easy to re-activate ldap automaps by 
creating a file in /etc/auto.master.d with this formula (new map with no 
entities)


Except for the auto.master file this formula does not delete existing content
in map files.


So if you manage your existing /etc/auto.direct map with it, new mounts will
be added and existing mountpoints will stay untouched if they are not defined
as an entity. 

If an existing line is defined as an entity in this formula, 
it will will be updated if the defined configuration differs from the existing 
configuration.
