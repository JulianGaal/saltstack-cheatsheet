set screensaver:
  file.recurse:
    - name: /Library/Screen Savers/WatchOSX.saver
    - source: salt://media/WatchOSX.saver

  cmd.script:
    - name: screensaver
    - source: salt://media/setscreensaver.sh
    - unless: /usr/bin/defaults -currentHost read com.apple.screensaver "moduleDict" | grep WatchOSX.saver
