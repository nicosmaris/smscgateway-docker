[![Travis build status](https://travis-ci.org/nicosmaris/smscgateway-docker.png?branch=master)](https://travis-ci.org/nicosmaris/smscgateway-docker)

# smscgateway-docker

The last command below assumes that there is a cassandra at localhost, so if you have one already, you can skip the first command.

docker run --name db --net=host -p 127.0.0.1:9042:9042 -p 127.0.0.1:9160:9160 -d cassandra
docker run --name smsc --net=host -p 0.0.0.0:8080:8080 -d restcomm/smsc
 

