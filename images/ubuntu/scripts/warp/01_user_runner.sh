#!/bin/bash

#create runner user and add the user to relevant groups
echo 'Create runner user'
adduser --disabled-password --gecos "" runner
echo 'runner:runner' | chpasswd
echo 'runner ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
usermod -aG sudo,admin,adm,docker,systemd-journal runner

# Set root password for debugging access
echo 'set root pass'
echo 'root:root' | chpasswd
