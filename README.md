# datacrypt

Provides an encrypted filesystem on a Docker host

## run container

```bash
docker run -d --privileged -e CRYPT_KEY_URL --name enc --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --cap-add MKNOD -v /mnt:/mnt -v /dev:/dev 300481/datacrypt
```

## environment

The container must be configured by Environment Variables.

The `CRYPT_KEY_URL` is mandatory.

|Variable|Description|Default|
|--------|-----------|-------|
|`DATA_PATH`|Path to mount encrypted filesystem to. Must be below `/mnt`.|`/mnt/data`|
|`CRYPT_KEY_URL`|HTTP URL to the encryption key.||
|`CRYPT_CONTAINER_SIZE_PERCENTAGE`|Percentage of the free disk space for the enrypted container.|`80`|

## cloud-config snippet for RancherOS

```yaml
rancher:
  environment:
    CRYPT_KEY_URL: http://url.to.your.key
  repositories:
    datacrypt:
      url: https://raw.githubusercontent.com/300481/datacrypt/master
  services_include:
    datacrypt: true
```

## Related Article

To get more information regarding the purpose of this container image, please see my article on [Medium](https://dennis-riemenschneider.medium.com/how-to-encrypt-your-headless-linux-server-2de9c7f0f972)
