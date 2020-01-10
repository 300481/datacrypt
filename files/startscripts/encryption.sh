#!/bin/bash

# path to make data storage available
: ${DATA_PATH:="/mnt/data"}

# URL of the encryption key
: ${CRYPT_KEY_URL:=""}

# Percentage of free disk space to use for the encrypted container
: ${CRYPT_CONTAINER_SIZE_PERCENTAGE:="80"}
CRYPT_CONTAINER="/mnt/crypt-container"

# write available loop device into file
losetup -f > /tmp/loopdev

# write data path into a file
echo ${DATA_PATH} > /tmp/datapath

create_container() {
    # get available loop device
    LOOPDEV=$(losetup -f)

    # create container file
    echo "create crypto container"
    FREE=$(df /mnt -BM --output=avail | tail -1 | sed 's/M//')
    USE=$(( FREE * CRYPT_CONTAINER_SIZE_PERCENTAGE / 100 ))
    dd if=/dev/zero of=${CRYPT_CONTAINER} bs=1M count=1 seek=$(( USE - 1 ))
    
    # mount container file into loop device
    losetup ${LOOPDEV} ${CRYPT_CONTAINER}

    # encrypt container
    curl ${CRYPT_KEY_URL} | cryptsetup -v --debug -c aes-xts-plain64 -s 512 -h sha512 -d - -q luksFormat ${LOOPDEV}

    # open container
    curl ${CRYPT_KEY_URL} | cryptsetup -v --debug -d - luksOpen ${LOOPDEV} container

    # create file system
    echo "create file system in crypto container"
    mkfs.ext4 /dev/mapper/container
}

open_container() {
    echo "open crypto container"
    # get available loop device
    LOOPDEV=$(losetup -f)
    # mount container file into loop device
    losetup ${LOOPDEV} ${CRYPT_CONTAINER}
    # open container
    curl ${CRYPT_KEY_URL} | cryptsetup -v --debug -d - luksOpen ${LOOPDEV} container
}

init_encryption() {
    # if no key given, exit with error
    if [[ -z ${CRYPT_KEY_URL} ]] ; then
        echo "ERROR: Could not create encrypted container. please provide CRYPT_KEY_URL!"
        sleep 60
        exit 1
    fi

    # if data path don't exist, create it
    [[ ! -d ${DATA_PATH} ]] && mkdir -p ${DATA_PATH}

    # if crypt container file don't exist, create it, otherwise just open it
    [[ ! -f ${CRYPT_CONTAINER} ]] && create_container || open_container    

    # mount container
    echo "mount crypto container"
    mount -t ext4 /dev/mapper/container ${DATA_PATH}

    # keep docker container running
    tail -f /dev/null
}

init_encryption