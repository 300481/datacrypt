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

## Butane config for Fedora CoreOS

**Use this only when installing with the current Fedora CoreOS version!!!**

Find the current download [here](https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable)

```yaml
systemd:
  units:
    - name: datacrypt.service
      enabled: true
      contents: |
        [Unit]
        Description=Encryption at rest
        Before=systemd-user-sessions.service
        After=network-online.target
        [Service]
        Type=exec
        Environment=CRYPT_KEY_URL='<<<YOUR_KEY_URL_HERE>>>' CRYPT_CONTAINER_SIZE_PERCENTAGE='<<<YOUR_PERCENTAGE_HERE>>>'
        ExecStart=/usr/local/bin/encryption-start.sh
        ExecStop=/usr/local/bin/encryption-stop.sh
        [Install]
        WantedBy=multi-user.target
storage:
  files:
    - path: /usr/local/bin/encryption-start.sh
      mode: 0755
      contents:
        source: https://raw.githubusercontent.com/300481/datacrypt/fcos-0.2.0/files/startscripts/encryption.sh
    - path: /usr/local/bin/encryption-stop.sh
      mode: 0755
      contents:
        source: https://raw.githubusercontent.com/300481/datacrypt/fcos-0.2.0/files/stopscripts/shutdown.sh
```

## Related Article

To get more information regarding the purpose of this container image, please see my article on [Medium](https://dennis-riemenschneider.medium.com/how-to-encrypt-your-headless-linux-server-2de9c7f0f972)
