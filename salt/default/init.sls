include:
  - default.locale
  {% if not grains['osfullname'] == 'SLE Micro' %}  #  Read-only file system: '/var/lib/rpm/.rpm.lock
  - default.minimal
  {% endif %}
  - default.pkgs
  - default.grub
  - default.sshd
  {% if grains.get('reset_ids') | default(false, true) %}
  - default.ids
  {% endif %}
  {% if not grains['osfullname'] == 'SLE Micro' %}  #  Read-only file system: '/var/lib/rpm/.rpm.lock
  - default.testsuite
  {% endif %}

{% if grains.get('use_os_released_updates') | default(False, true) %}
update_packages:
  pkg.uptodate:
    - require:
      - sls: repos
{% endif %}

{% if grains.get('swap_file_size', "0")|int() > 0 %}
file_swap:
  cmd.run:
    - name: |
        {% if grains['os_family'] == 'RedHat' %}dd if=/dev/zero of=/extra_swapfile bs=1048576 count={{grains['swap_file_size']}}{% else %}fallocate --length {{grains['swap_file_size']}}MiB /extra_swapfile{% endif %}
        chmod 0600 /extra_swapfile
        mkswap /extra_swapfile
    - creates: /extra_swapfile
  mount.swap:
    - name: /extra_swapfile
    - persist: true
    - require:
      - cmd: file_swap
{% endif %}

{% if grains['authorized_keys'] %}
authorized_keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - text:
{% for key in grains['authorized_keys'] %}
      - {{ key }}
{% endfor %}
    - makedirs: True
{% endif %}
