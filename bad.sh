#!/bin/sh

ALREADYMOUNTED="no"
CHROOT_DIR="/tmp/alpine"

if mount | grep -q "$CHROOT_DIR" ; then
    ALREADYMOUNTED="yes"
    echo "ATTENTION! Alpine's rootfs is already mounted. You'll be dropped into it."
    echo "Leave this shell carefully—no umount will be done to avoid disrupting other sessions."
else
    echo "Mounting Alpine rootfs"
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

smin_val=$((10#$(date +%H) * 60 + 10#$(date +%M) + 1))

json=$(cat <<EOF
{
  "enable": 1,
  "wday": [1, 1, 1, 1, 1, 1, 1],
  "stime_opt": 0,
  "smin": $smin_val,
  "soffset": 0,
  "etime_opt": -1,
  "emin": 0,
  "eoffset": 0,
  "eact": -1,
  "repeat": 1,
  "year": 2000,
  "month": 1,
  "day": 1,
  "name": "yay",
  "id": "00963AAC3513BAC237960D423514CDF5",
  "sact": 1
}
EOF
)

chroot /tmp/alpine kasa --host 192.168.42.3 command --module schedule edit_rule "$json" > /dev/null