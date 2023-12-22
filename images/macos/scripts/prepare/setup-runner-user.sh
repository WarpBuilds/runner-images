#!/bin/bash

RUNNER_USER='runner'


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
  -password $RUNNER_USER \
  -home /Users/$RUNNER_USER \
  -admin

sudo dscl . -create /Users/$RUNNER_USER PrimaryGroupID "$curr_group"

sudo cp -R /Users/$curr_user/ /Users/$RUNNER_USER/
sudo chown -R $RUNNER_USER /Users/$RUNNER_USER

# Enable SSH (Remote Login)
sudo systemsetup -setremotelogin on
