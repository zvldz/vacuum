# VACUUM firmware

### Features:
* Added ssh banner (with ip, token, firmware version and etc)
* Added wget, nano, htop, bbe, mini_snmpd
* Password has been set for users of root and cleaner (pass: cleaner)
* Installed Valetudo (https://github.com/Hypfer/Valetudo)
* Patched rrlogd to disable map encryption (https://github.com/JohnRev/rrlogd-patcher)
* Set dns-server to 8.8.8.8 and 114.114.114.114
* Firmware with suffix 2prc converts to Chinese version
* Firmware with suffix 2eu  converts to EU version
* Disabled Chinese greetings Happy New Year
* Disabled log upload to the cloud (but not map)

Script builder_vacuum.sh based on imagebuilder.sh from https://github.com/dgiese/dustcloud

### Thanks
* https://github.com/dgiese/dustcloud
* https://github.com/JohnRev/rrlogd-patcher
* https://github.com/Hypfer/Valetudo
* https://github.com/LazyT/rrcc
