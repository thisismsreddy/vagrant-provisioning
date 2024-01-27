#!/bin/bash


echo "[TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 9] Set root password"
echo -e "msreddy\nmsreddy" | passwd root >/dev/null 2>&1

echo "Install podman"
dnf -y install podman
dnf install -y --assumeyes centos-release-ceph-quincy
dnf install -y --assumeyes cephadm
dnf install -y python-requests git

# Get the IP address of eth0
MON_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Check if the IP was successfully retrieved
if [ -z "$MON_IP" ]; then
    echo "Failed to obtain IP address for eth0"
    exit 1
fi

# Run the cephadm bootstrap command with the dynamically obtained IP
cephadm bootstrap --mon-ip $MON_IP --initial-dashboard-password root1234 \
  --dashboard-password-noupdate --allow-fqdn-hostname --log-to-file --single-host-defaults

dnf install ceph-common -y

# ceph orch apply osd --all-available-devices

# sleep 3m

# ceph osd pool create volumes 16 16 replicated
# ceph config set global mon_allow_pool-mean-it_size_one true
# ceph osd pool set volumes size 1  --yes-i-really-mean-it
# rbd pool init volumes


# git clone --single-branch --branch v1.12.8 https://github.com/rook/rook.git

# # git clone --single-branch --branch v1.12.8 https://github.com/rook/rook.git