#!/bin/sh
# Shell script to set Q1 screensaver
/usr/bin/defaults -currentHost write com.apple.screensaver "moduleDict" -dict-add "path" -string "/Library/Screen\ Savers/WatchOSX.saver"

/usr/bin/defaults -currentHost write com.apple.screensaver 'idleTime' -int "60"
