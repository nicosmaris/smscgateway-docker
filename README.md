[![Travis build status](https://travis-ci.org/RestComm/smscgateway-docker.png?branch=master)](https://travis-ci.org/RestComm/smscgateway-docker)

# smscgateway-docker

The last command below assumes that there is a cassandra at localhost, so if you have one already, you can skip the first command.

`docker run --name db --net=host -p 127.0.0.1:9042:9042 -p 127.0.0.1:9160:9160 -d cassandra`

`docker run --name smsc --net=host -e ENVCONFURL="https://raw.githubusercontent.com/RestComm/smscgateway-docker/master/env_files/restcomm_env_smsc_locally.sh" -p 0.0.0.0:8080:8080 -d restcomm/smscgateway-docker`

# Environment variables

Optionally, if the environment variable ENVCONFURL is given at 'docker run', this file download a script from the url ENVCONFURL and adds it at the terminal, otherwise it follows the default settings of scripts/restcomm_smsc_service.sh

# Logs

To read jboss logs of your container (assuming that it is named smsc) you can run 'docker logs smsc'. The same output along with more OS-level logs can be captured with the following command:

```
provisioner/docker_do.sh -c smsc -l
```


The above command copies container logs to the host. To read them, type:

```
sudo bash -c "find /var/log/restcomm*/host -type f -exec cat {} \;"
```


# Contribute to RestComm

https://github.com/RestComm/Restcomm-Connect/wiki/Contribute-to-RestComm

This docker is based on phusion/baseimage which comes with an init process /sbin/my_init and runit to run scripts at /etc/service/*/run/ as daemons.

1. The file scripts/automate_conf.sh is added at the image as /etc/my_init.d/restcommautomate.sh and thus it runs upon startup
2. The file scripts/restcomm_smsc_service.sh runs as a daemon. The file scripts/restcomm_toolsconf.sh adds the folder /etc/service/restcomm and moves it to /etc/service/restcomm/run

# Issues

1. push image from travis to docker hub
2. tcpdump cron and logs
3. env_files without smsc in their filename

