#!/bin/bash

# deluser --remove-home ankit

# Comments out the secure_path line in /etc/sudoers as it was overwriting our $PATH var in new user accounts
sed -i 's/^Defaults[ \t]*secure_path/# Defaults secure_path/' /etc/sudoers
sed -i 's/^Defaults[ \t]*env_reset/# Defaults env_reset/' /etc/sudoers

#create runner user and add the user to relevant groups
echo 'Create runner user'
adduser --disabled-password --gecos "" runner
echo 'runner:runner' | chpasswd
echo 'runner ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
usermod -aG sudo,admin,adm,docker,systemd-journal runner

# Set root password for debugging access
echo 'set root pass'
echo 'root:root' | chpasswd

# Export the PATH variable to the runner user's .bashrc and .profile
sudo sh -c 'echo "export PATH=$(grep ^PATH= /etc/environment | head -n 1)" >> /home/runner/.bashrc'
sudo sh -c 'echo "export PATH=$(grep ^PATH= /etc/environment | head -n 1)" >> /home/runner/.profile'


# apply these to generalize VM
# https://learn.microsoft.com/en-us/azure/virtual-machines/generalize

# capture the image of generalized VM  and create new VM with generalized image to proceed with further steps

# execute this in the new generalized VM once more to cleanup the users provisioned through azure
waagent -deprovision+user

# continue with other scripts
