# SaltStack MacOS Deploy

This is an example SaltStack configuration

The `srv` directory needs to be placed in your root directory. For this example to work, your minions have to be running MacOS.

## File Structure
```
   ├── srv/
   │   ├── pillar/
   │   │   ├── top.sls
   │   │   ├── wificonfig.sls
   │   ├── salt/
   │   │   ├── top.sls
   │   │   ├── wifi
   │   │   │   ├── init.sls
   │   │   │   ├── setwificonfig.sh
   │   │   │   ├── wifi.mobileconfig
   │   │   ├── media
   │   │   │   ├── init.sls
   │   │   │   ├── setscreensaver.sh
   │   │   │   ├── Q1.saver
   ```
All sensitive data is saved in a SaltStack 'Pillar'. Remove any sensitive data from the original config file and replace the space with Jinja code, and *inject* it into your config files, e.g. with
```
file.managed:
  - source: salt://wifi/wifi.mobileconfig
  - template: jinja
```
## Includes
* [WiFi Configuration]()
* [Screensaver]()
