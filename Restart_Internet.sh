#!/bin/sh

ALREADYMOUNTED="no"
CHROOT_DIR="/tmp/alpine"

if mount | grep -q "$CHROOT_DIR" ; then
    ALREADYMOUNTED="yes"
else
    echo "Getting things started..."
    mkdir -p "$CHROOT_DIR"
    mount -o loop,noatime -t ext3 /mnt/base-us/alpine.ext3 "$CHROOT_DIR"
    mount -o bind /dev "$CHROOT_DIR/dev"
    mount -o bind /dev/pts "$CHROOT_DIR/dev/pts"
    mount -o bind /proc "$CHROOT_DIR/proc"
    mount -o bind /sys "$CHROOT_DIR/sys"
    mount -o bind /var/run/dbus/ "$CHROOT_DIR/run/dbus/"
    cp /etc/hosts "$CHROOT_DIR/etc/hosts"
    chmod a+w /dev/shm
fi

cat << 'EOF' > "$CHROOT_DIR/root/kasa_run.sh"
#!/bin/sh

SMIN=$(((((10#$(date -u +%H) * 60 + 10#$(date -u +%M) + 1))-420)%1440))
echo 'Adding command to turn the plug back on...'
kasa --host 192.168.42.3 raw-command schedule edit_rule "{\"enable\": 1, \"wday\": [1,1,1,1,1,1,1], \"stime_opt\": 0, \"smin\": $SMIN, \"soffset\": 0, \"etime_opt\": -1, \"emin\": 0, \"eoffset\": 0, \"eact\": -1, \"repeat\": 1, \"year\": 2000, \"month\": 1, \"day\": 1, \"name\": \"yay\", \"id\": \"00963AAC3513BAC237960D423514CDF5\", \"sact\": 1}" > /dev/null
echo 'Turning off the smart plug...'
kasa --host 192.168.42.3 off > /dev/null
echo 'Done! The internet should be back up in about two minutes.'
sleep 4
EOF

chmod +x "$CHROOT_DIR/root/kasa_run.sh"

# enter chroot and execute
chroot "$CHROOT_DIR" /root/kasa_run.sh