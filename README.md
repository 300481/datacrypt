# rancheros-data-encryption

Provides an encrypted filesystem on a RancherOS host

## run container

```bash
docker run -d --privileged -e CRYPT_KEY_URL --name enc --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --cap-add MKNOD -v /mnt:/mnt -v /dev:/dev 300481/rancheros-data-encryption
```
