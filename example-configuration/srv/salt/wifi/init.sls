{% if grains['os'] == 'MacOS' %}
# Applies Ninja template and sends it to minion
/tmp/wifi.mobileconfig:
  file.managed:
    - source: salt://wifi/wifi.mobileconfig
    - template: jinja

wifi set:
  cmd.script:
    - name: wifi
    - source: salt://wifi/setwificonfig.sh
    - unless: sudo /usr/bin/profiles -P | grep {{ pillar['identifier'] }}

{% endif %}
