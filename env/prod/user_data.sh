#!/bin/bash
set -euxo pipefail

# Update packages
apt-get update -y
apt-get upgrade -y

# Install Nginx
apt-get install -y nginx

# Start and enable Nginx
systemctl start nginx
systemctl enable --now nginx

# Wait for EBS to attach
sleep 15


# Create mount directory
mkdir -p /data

# Wait for the EBS disk to appear (non-root NVMe disk)
DEVICE=""

for i in {1..30}; do
  # List disks, exclude the root disk (usually nvme0n1)
  DEVICE=$(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print $1}' | grep -v '^nvme0n1$' | head -n 1 || true)
  if [ -n "$DEVICE" ] && [ -b "/dev/$DEVICE" ]; then
    DEVICE="/dev/$DEVICE"
    break
  fi
  sleep 2
done

if [ -z "${DEVICE}" ]; then
  echo "ERROR: EBS device not found"
  exit 1
fi

# Format disk only if it has no filesystem
if ! blkid "${DEVICE}" >/dev/null 2>&1; then
  mkfs.ext4 -F "${DEVICE}"
fi

# Mount disk
UUID=$(blkid -s UUID -o value "${DEVICE}")
mount -U "${UUID}" /data

# Persist mount (avoid duplicate entries)
grep -q "UUID=${UUID} /data" /etc/fstab || echo "UUID=${UUID} /data ext4 defaults,nofail 0 2" >> /etc/fstab

