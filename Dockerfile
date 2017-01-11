FROM phusion/baseimage:latest
# this docker holds the jboss of SMSC and the initial db scripts

#MAINTAINER TBD

# installs first the db client (cqlsh) and java 7.
ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_DIR /opt/Restcomm-SMSC

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true |  /usr/bin/debconf-set-selections && \
locale-gen en_US en_US.UTF-8 && \
dpkg-reconfigure locales && \
add-apt-repository ppa:webupd8team/java -y && \
apt-cache search mysql-client-core && \
apt-get update && \
apt-get install -y \
screen wget ipcalc bsdtar oracle-java7-installer \
mysql-client-core-5.7 openssl unzip nfs-common dnsutils net-tools \
oracle-java7-set-default \
lksctp-tools && \
curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python && \
pip install cqlsh && \
apt-get autoremove && \
apt-get autoclean && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p ${INSTALL_DIR}

# downloading 330MB is faster than downloading the maven dependencies and compiling the source
RUN wget -qO- https://mobicents.ci.cloudbees.com/job/RestComm-SMSC/lastSuccessfulBuild/artifact/smsc-version.txt -O version.txt && \
mv version.txt /tmp/version
RUN wget -qc https://mobicents.ci.cloudbees.com/job/RestComm-SMSC/lastSuccessfulBuild/artifact/release/restcomm-smsc-`cat /tmp/version`.zip -O restcomm-smsc.zip && \
unzip -qq restcomm-smsc.zip -d /opt/ && \
mv /opt/restcomm-smsc-*/*/ ${INSTALL_DIR} && \
rm restcomm-smsc.zip && \
rm -rf ${INSTALL_DIR}/docs && \
rm -rf ${INSTALL_DIR}/cassandra && \
rm -rf ${INSTALL_DIR}/jboss-5.1.0.GA/server/default && \
echo "SMSC verion: `cat /tmp/version`" > ${INSTALL_DIR}/version

RUN ls -la ${INSTALL_DIR}
RUN chmod +x ${INSTALL_DIR}/jboss-5.1.0.GA/bin/*
RUN mkdir -p ${INSTALL_DIR}/jboss-5.1.0.GA/server/simulator/log
ENV jboss.server.name simulator

# add files for SSL and logging
ADD ./ca-startcom.der ${INSTALL_DIR}/jboss-5.1.0.GA/ca-startcom.der

# the entrypoint of phusion baseimage is rinit
CMD ["/sbin/my_init"]
RUN mkdir -p /etc/my_init.d
ADD ./scripts/automate_conf.sh /etc/my_init.d/restcommautomate.sh
ADD ./scripts/restcomm_setenv.sh /tmp/.restcommenv.sh
RUN chmod +x /etc/my_init.d/restcomm*.sh
#RUN chmod +x /tmp/.restcommenv.sh

# jboss starts as a service of phusion baseimage
RUN mkdir -p /etc/service/restcomm
ADD ./scripts/restcomm_smsc_service.sh /etc/service/restcomm/run

# attaching jboss log files to 'docker logs'
RUN ln -sf /dev/stdout /opt/Restcomm-SMSC/version
RUN ln -sf /dev/stdout /opt/Restcomm-SMSC/jboss-5.1.0.GA/server/simulator/log/server.log
RUN ln -sf /dev/stdout /opt/Restcomm-SMSC/jboss-5.1.0.GA/server/simulator/log/boot.log

EXPOSE 8080 
