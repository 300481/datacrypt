#!/bin/bash

LOOPDEV=$(</tmp/loopdev)
DATA_PATH=$(</tmp/datapath)

close_encryption() {
    # write cache
    echo "write cache"
    sync
    # unmount 
    echo "unmount ${DATA_PATH}"
    mount | grep -q "${DATA_PATH}" && umount ${DATA_PATH}
    # close container
    echo "close container"
    [[ -L /dev/mapper/container ]] && cryptsetup close container
    # detach loop device
    echo "detach loop device"
    losetup -d ${LOOPDEV}
}

close_encryption