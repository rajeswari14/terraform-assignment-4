#!/bin/bash
# Update packages
apt-get update -y
apt-get upgrade -y

# Install Nginx
apt-get install -y nginx

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Wait for EBS to attach
sleep 15

# Format disk if not formatted
if ! blkid /dev/nvme1n1; then
  mkfs.ext4 /dev/nvme1n1
fi

# Create mount directory
mkdir -p /data

# Mount using UUID
UUID=$(blkid -s UUID -o value /dev/nvme1n1)
mount UUID=$UUID /data

# Persist mount
echo "UUID=$UUID /data ext4 defaults,nofail 0 2" >> /etc/fstab
