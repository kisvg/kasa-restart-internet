#!/bin/bash

ALREADYMOUNTED="no"
if [ "$(mount | grep /tmp/alpine)" ] ; then
	ALREADYMOUNTED="yes"
	echo "ATTENTION! Alpine's rootfs is already mounted, thus you will be just dropped into it."
	echo "BE CAREFUL to leave this shell first, as there will be no umount either (To not disturb the other session)."
   else
	echo "Mounting Alpine rootfs"
	mkdir -p /tmp/alpine
	mount -o loop,noatime -t ext3 /mnt/base-us/alpine.ext3 /tmp/alpine
	mount -o bind /dev /tmp/alpine/dev
	mount -o bind /dev/pts /tmp/alpine/dev/pts
	mount -o bind /proc /tmp/alpine/proc
	mount -o bind /sys /tmp/alpine/sys
	mount -o bind /var/run/dbus/ /tmp/alpine/run/dbus/
	cp /etc/hosts /tmp/alpine/etc/hosts
	chmod a+w /dev/shm
fi

echo 'Adding command to turn the plug back on...'
chroot /tmp/alpine kasa --host 192.168.42.3 raw-command schedule edit_rule "{\"enable\": 1,\"wday\": [1, 1, 1, 1, 1, 1, 1],\"stime_opt\": 0,\"smin\":$((10#$(date +%H) * 60 + 10#$(date +%M) + 1)) ,\"soffset\": 0,\"etime_opt\": -1,\"emin\": 0,\"eoffset\": 0,\"eact\": -1, \"repeat\": 1, \"year\": 2000, \"month\": 1, \"day\": 1, \"name\":\"yay\", \"id\": \"00963AAC3513BAC237960D423514CDF5\", \"sact\": 1}" > /dev/null
echo 'Turning off the smart plug...'
chroot /tmp/alpine kasa --host 192.168.42.3 off > /dev/null
echo 'Done! The internet should be back up in about two minutes.'