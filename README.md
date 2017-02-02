# SaltStack Cheat Sheet

This list is partly inspired by the fine lists on:
* http://www.xenuser.org/saltstack-cheat-sheet/
* https://github.com/saltstack/salt/wiki/Cheat-Sheet

# Documentation
This is important because the help system is very good.

## Networking
In order to run, Salt needs to keep open the following communication ports
* Job publisher port on TCP 4505 port. 
* An open TCP 4506 port to minion's return.

### iptables rules
```
iptables -A INPUT -m state --state new -m tcp -p tcp --dport 4505 -j ACCEPT
iptables -A INPUT -m state --state new -m tcp -p tcp --dport 4506 -j ACCEPT
```
Persist across system restart
```
iptables-save > /etc/iptables.rules
```

## Documentation on the system
```
salt '*' sys.doc         # output sys.doc (= all documentation)
salt '*' sys.doc pkg     # only sys.doc for pkg module
salt '*' sys.doc network # only sys.doc for network module
salt '*' sys.doc system  # only sys.doc for system module
salt '*' sys.doc status  # only sys.doc for status module
```

## Documentation on the web
- SaltStack documentation: http://docs.saltstack.com/en/latest/
- Salt-Cloud: http://docs.saltstack.com/en/latest/topics/cloud/
- Jobs: http://docs.saltstack.com/en/latest/topics/jobs/

# Minions

## Minion status
You can also use several commands to check if minions are alive and kicking but I prefer manage.status/up/down.

```
salt-run manage.status  # What is the status of all my minions? (both up and down)
salt-run manage.up      # Any minions that are up?
salt-run manage.down    # Any minions that are down?
salt '*' test.ping      # Use test module to check if minion is up and responding.
                        # (Not an ICMP ping!)
```

## Target minion with state files
Look at the SLS files
```
salt 'minion1' state.show_sls some_sls	# Parse and show SLS file
```
Apply a specific state file to a (group of..) minion(s). Do not use the .sls extension. (just like in the state files!)
```
salt '*' state.sls mystatefile          # mystatefile.sls will be applied to *
salt 'minion1' state.sls prod.somefile  # prod/somefile.sls will be applied to minion1
```
Apply a state in *debug* mode
```
salt '*' state.apply state -l debug
```
Test a SLS before apply and print only differences (`--output-diff`)
```
salt '\*' state.apply state test=true --output-diff
```
Or bring the specified target to the *highstate*
```
salt 'minion1' state.highstate          # Apply hihgstate over matching minions
```

## Grains
List all grains on all minions
```
salt '*' grains.ls
```

Look at a single grains item to list the values.
```
salt '*' grains.item os      # Show the value of the OS grain for every minion
salt '*' grains.item roles   # Show the value of the roles grain for every minion
```

Manipulate grains.
```
salt 'minion1' grains.setval mygrain True  # Set mygrain to True (create if it doesn't exist yet)
salt 'minion1' grains.delval mygrain       # Delete the value of the grain
```

## Pillars
Look at pillars and get values
```
salt 'minion1' pillar.get pillar	      # Get pillar
salt 'minion1' pillar.item pillar	      # Print pillar items
salt 'minion1' pillar.ls                # Show available main keys

salt '*' pillar.get pkg:apache          # Show pkg:apache pillar
salt '*' pillar.file_exists foo/bar.sls # Return true if pillar file exist
salt '*' saltutil.refresh_pillar        # Reload pillars
```

# Jobs in Salt
Some jobs operations that are often used. (http://docs.saltstack.com/en/latest/topics/jobs/)
```
salt-run jobs.active                      # get list of active jobs
salt-run jobs.list_jobs                   # get list of historic jobs
salt-run jobs.lookup_jid <job id number>  # get details of this specific job
```

# Sysadmin specific
Some stuff that is specifically of interest for sysadmins.

## System and status
```
salt 'minion-x-*' cmd.run 'command'   # Run command on minions
salt 'minion-x-*' system.reboot       # Let's reboot all the minions that match minion-x-*
salt '*' status.uptime                # Get the uptime of all our minions
```
Or work with process and check filesystems
```
salt '*' ps.disk_usage /home	        # Print disk usage for /home partition
salt '*' ps.disk_partitions		        # Return a list of disk partitions and their device, mount point, and filesystem type.
salt '*' ps.get_users			            # Return logged users
salt 'minion' ps.kill_pid pid [signal=signal_number] # Send kill signal to an specific PID
salt '*' ps.psaux www-data.+apache2	  # Return process matching with the string
```

## Packages
```
salt '*' pkg.list_upgrades              # get a list of packages that need to be upgrade
salt '*' pkg.upgrade                    # Upgrades all packages via apt-get dist-upgrade (or similar)

salt '*' pkg.version bash               # get current version of the bash package
salt '*' pkg.install bash               # install or upgrade bash package
salt '*' pkg.install bash refresh=True  # install or upgrade bash package but
                                        # refresh the package database before installing.
```

## Check status of a service and manipulate services
```
salt '*' service.status <service name>
salt '*' service.available <service name>
salt '*' service.enable <service name>
salt '*' service.start <service name>
salt '*' service.restart <service name>
salt '*' service.stop <service name>
salt '*' service.disable <service name>
```

## Network

Do some network stuff on your minions.

```
salt 'minion1' network.ip_addrs                 # Get IP of your minion
salt 'minion1' network.ping <hostname>          # Ping a host from your minion
salt 'minion1' network.traceroute <hostname>    # Traceroute a host from your minion
salt 'minion1' network.get_hostname             # Get hostname
salt 'minion1' network.mod_hostname             # Modify hostname
```

# Salt Cloud
Salt Cloud is used to provision virtual machines in the cloud. (surprise!) (http://docs.saltstack.com/en/latest/topics/cloud/)

```
salt-cloud -p profile_do my-vm-name -l debug  # Provision using profile_do as profile
                                              # and my-vm-name as the virtual machine name while
                                              # using the debug option.
salt-cloud -d my-vm-name                      # destroy the my-vm-name virtual machine.
salt-cloud -u                                 # Update salt-bootstrap to latest develop version on GitHub.
```

# Salt keys
Accept or deny a minion to connecting master based on the public key.
* *RSA keys* used for authentication.
* *AES key* usad for encryption

The AES key is changed every *24 hours* by default or when a minion has been deleted.

Salt minion keys can be in one of the following states:

* **unaccepted:** key is waiting to be accepted.
* **accepted:** key was accepted and the minion can communicate with the Salt master.
* **rejected:** key was rejected using the salt-key command. In this state the minion does not receive any communication from the Salt master.
* **denied:** key was rejected automatically by the Salt master. This occurs when a minion has a duplicate ID, or when a minion was rebuilt or had new keys generated and the previous key was not deleted from the Salt master. In this state the minion does not receive any communication from the Salt master.

To change the state of a minion key, use -d to delete the key and then accept or reject the key.

The `pki_dir` is a configurable directory on `/etc/salt/pki/minion/`. The `minions` directory contains:
* `accepted minion` keys.
* `minions_pre` pending acceptance keys
* `minions_rejected` keys which have been rejected

```
salt-key -l 	        # List the public keys
salt-key -L 	        # List all public keys 
salt-key -a 'minion1'	# Accept minion1 public key
salt-key -A 	        # Accept ALL public keys
salt-key -r	        	# Reject a public key
salt-key -R		        # Reject ALL public keys
salt-key -p		        # Print the specified public key
salt-key -P		        # Print all public keys
salt-key -d 'minion1' # Delete minion1 public key
salt-key -D 	        # Delete ALL public keys
salt-key -f master    # Get the public signature for your local master
```
