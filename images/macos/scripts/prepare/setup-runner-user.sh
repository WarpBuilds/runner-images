#!/bin/bash

set -e -o pipefail

RUNNER_USER='runner'
RUNNER_PASS=''


echo "A user $RUNNER_USER will be created to run the agent."

echo "Getting current group"
curr_group=$(id -gn)
echo "Current group: $curr_group"

echo "Getting current user"
curr_user=$(id -un)
echo "Current user: $curr_user"

echo "Creating new runner user through sysadminctl with admin privileges"
sudo sysadminctl \
  -addUser $RUNNER_USER \
  -fullName $RUNNER_USER \
  -password $RUNNER_PASS \
  -home /Users/$RUNNER_USER \
  -admin

echo "Adding $RUNNER_USER to $curr_group"
sudo dscl . -create /Users/$RUNNER_USER PrimaryGroupID "$curr_group"

echo "Adding $RUNNER_USER to sudoers"
sudo dscl . -append /Groups/admin GroupMembership $RUNNER_USER

echo "List all users"
dscl . list /Users | grep -v '^_'

echo "Copying $curr_user home directory to $RUNNER_USER"
sudo cp -R /Users/$curr_user/ /Users/$RUNNER_USER/
echo "Changing ownership of $RUNNER_USER home directory to $RUNNER_USER"
sudo chown -R $RUNNER_USER:$curr_group /Users/$RUNNER_USER

# Enable SSH (Remote Login)
sudo systemsetup -setremotelogin on
