#cloud-config
packages:
  - wget
  - ntpdate

network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        -10.0.0.51/24
      gateway4: 10.0.0.1
      nameservers:
        addresses: [10.0.0.1]
      routes:
        -to: default
        -via: 10.0.0.1

users:
  - default
  - name: ${USER}
    sudo: ALL=(ALL) NOPASSWD:ALL
    # een list in tfvars file is nog niet gelukt
    ssh_authorized_keys:
      - ${KEY}
    shell: /bin/bash
runcmd:
  - hostnamectl set-hostname ${HOSTNAME}
  - date >>/root/cloudinit.log 
  - echo ${HELLO} >>/root/cloudinit.log

