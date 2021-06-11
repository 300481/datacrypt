#!/bin/bash

LOOPDEV=$(</tmp/loopdev)

close_encryption() {
    # write cache
    echo "write cache"
    sync
    # unmount 
    echo "unmount /dev/mapper/container"
    mount | grep -q "/dev/mapper/container" && umount /dev/mapper/container
    # close container
    echo "close container"
    [[ -L /dev/mapper/container ]] && cryptsetup close container
    # detach loop device
    echo "detach loop device"
    losetup -d ${LOOPDEV}
}

close_encryption