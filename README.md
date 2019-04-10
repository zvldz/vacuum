# VACUUM firmware

### Features:
* Added ssh greeting (with ip, token, firmware version and etc)
* Added wget, nano, htop, bbe, snmpd (community: public)
* Set password for root
* Add custom user
* Install Valetudo (https://github.com/Hypfer/Valetudo)
* Install modified version Valetudo (0.2.3 without dummycloud)
* Patched rrlogd to disable map encryption (https://github.com/JohnRev/rrlogd-patcher)
* Set dns-server to 8.8.8.8 and 114.114.114.114
* Region conversion (CN 2 EU and EU 2 CN)
* Disable Chinese greetings Happy New Year
* Disable log upload to the cloud (but not map)
* Disable cores

Script builder_vacuum.sh based on imagebuilder.sh from https://github.com/dgiese/dustcloud

### Thanks
* https://github.com/dgiese/dustcloud
* https://github.com/JohnRev/rrlogd-patcher
* https://github.com/Hypfer/Valetudo
* https://github.com/LazyT/rrcc
