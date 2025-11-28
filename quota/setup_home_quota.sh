#!/bin/bash
# /home_new : quotas utilisateurs seulement (soft 500Mo, hard 700Mo)
# /data_new : quotas utilisateurs et groupes liés aux utilisateurs, inode-only

set -e

HOME_PART="/home_new"
HOME_SOFT=500000   # Ko
HOME_HARD=700000

DATA_PART="/data_new"
DATA_INODE_SOFT=10000
DATA_INODE_HARD=12000

echo "=============================="
echo "1️⃣ Configuration des quotas sur $HOME_PART"
sudo mount -o remount,usrquota $HOME_PART
sudo quotaoff $HOME_PART || echo "Quotas déjà désactivés"
sudo quotacheck -cuf $HOME_PART
sudo quotaon $HOME_PART

for user in $(cut -d: -f1,6 /etc/passwd | grep '/home' | awk -F: '{print $1}'); do
    sudo setquota -u $user $HOME_SOFT $HOME_HARD 0 0 $HOME_PART
done
sudo repquota $HOME_PART

echo "=============================="
echo "2️⃣ Configuration des quotas sur $DATA_PART"
sudo mount -o remount,usrquota,grpquota $DATA_PART
sudo quotaoff $DATA_PART || echo "Quotas déjà désactivés"
sudo quotacheck -cugf $DATA_PART
sudo quotaon $DATA_PART

for user in $(cut -d: -f1,6 /etc/passwd | grep '/home' | awk -F: '{print $1}'); do
    sudo setquota -u $user 0 0 $DATA_INODE_SOFT $DATA_INODE_HARD $DATA_PART
done

for group in $(cut -d: -f1,4 /etc/passwd | awk -F: '{print $4}' | sort -u); do
    sudo setquota -g $group 0 0 $DATA_INODE_SOFT $DATA_INODE_HARD $DATA_PART
done
sudo repquota $DATA_PART

echo "✅ Quotas configurés sur $HOME_PART et $DATA_PART"
