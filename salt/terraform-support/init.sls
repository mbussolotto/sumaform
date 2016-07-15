hosts_file:
  file.append:
    - name: /etc/hosts
    - text: "127.0.1.1 {{ grains['hostname'] }}.{{ grains['avahi-domain'] }} {{ grains['hostname'] }}"

set_transient_hostname:
  cmd.run:
    - name: hostnamectl set-hostname {{ grains['hostname'] }}.{{ grains['avahi-domain'] }}
    - onlyif: hostnamectl

hostname:
  cmd.run:
    - name: hostname {{ grains['hostname'] }}.{{ grains['avahi-domain'] }}
  file.managed:
    - name: /etc/hostname
    - text: {{ grains['hostname'] }}.{{ grains['avahi-domain'] }}

avahi:
  pkg.installed:
    - name: avahi
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "#domain-name=local"
    - repl: "domain-name={{ grains['avahi-domain'] }}"
  service.running:
    - name: avahi-daemon
    - require:
      - pkg: avahi
      - file: avahi
    - watch:
      - file: /etc/avahi/avahi-daemon.conf

# HACK: workaround for https://infra.nue.suse.com/SelfService/Display.html?id=49948
work_around_networking_issue:
  cmd.run:
    - name: ping -c 1 euklid.suse.de; true
