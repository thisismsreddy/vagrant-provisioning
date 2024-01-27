#!/bin/bash


echo "[TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 9] Set root password"
echo -e "msreddy\nmsreddy" | passwd root >/dev/null 2>&1

echo "Install podman"
dnf -y install podman
dnf install -y --assumeyes centos-release-ceph-reef
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
  --dashboard-password-noupdate --allow-fqdn-hostname --log-to-file

dnf install ceph-common -y

# ssh-copy-id -f -i /etc/ceph/ceph.pub root@192.168.121.233
#ssh-copy-id -f -i /etc/ceph/ceph.pub root@192.168.121.247
#ceph orch host add ceph2.example.com 192.168.121.233 _admin
# ceph orch host add ceph3.example.com 192.168.121.247 _admin
# ceph orch apply osd --all-available-devices
# ceph fs volume create cephfs
# ceph osd pool create volumes 32 32 replicated
# ceph osd pool application enable volumes rbd
# rbd pool init volumes
#git clone --single-branch --branch master https://github.com/rook/rook.git