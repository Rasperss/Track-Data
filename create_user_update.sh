#!/bin/bash

# Define variables
USERNAME="racing"
PASSWORD="ChangeMe!"
SUDO_GROUP="sudo"

# Check if the user already exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
else
    # Create the user with the specified password
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd

    # Add the user to the sudo group
    usermod -aG "$SUDO_GROUP" "$USERNAME"

    echo "User $USERNAME has been created and added to the sudo group, now updating server in 5 seconds."
fi
sleep 5
apt update && apt upgrade -y

# Reboot the server
echo "Rebooting the server in 10 seconds..."
sleep 10
reboot
