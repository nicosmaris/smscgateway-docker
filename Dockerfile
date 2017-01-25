FROM phusion/baseimage:latest
# this docker holds the jboss of SMSC and the initial db scripts

#MAINTAINER TBD

ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_DIR /opt/Restcomm-SMSC
ENV jboss.server.name default

# installs first the db client (cqlsh) and java 7. This docker layer is the only one that can be cached initially
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true |  /usr/bin/debconf-set-selections && \
locale-gen en_US en_US.UTF-8 && \
dpkg-reconfigure locales && \
add-apt-repository ppa:webupd8team/java -y && \
apt-cache search mysql-client-core && \
apt-get update && \
apt-get install -y \
screen wget ipcalc bsdtar oracle-java7-installer \
mysql-client-core-5.7 openssl unzip nfs-common dnsutils net-tools xmlstarlet \
oracle-java7-set-default \
lksctp-tools && \
curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python && \
pip install cqlsh && \
alias xml=xmlstarlet && ln -s /usr/bin/xmlstarlet /usr/bin/xml && \
apt-get autoremove && \
apt-get autoclean && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p ${INSTALL_DIR} && \
`# the entrypoint of phusion baseimage is rinit` \
mkdir -p /etc/my_init.d && \
`# jboss starts as a service of phusion baseimage` \
mkdir -p /etc/service/restcomm

# the entrypoint of phusion baseimage is rinit
ADD ./scripts/automate_conf.sh /etc/my_init.d/restcommautomate.sh
ADD ./scripts/restcomm_setenv.sh /tmp/.restcommenv.sh
CMD ["/sbin/my_init"]

# jboss starts as a service of phusion baseimage
ADD ./scripts/restcomm_smsc_service.sh /etc/service/restcomm/run

# downloading 330MB is faster than downloading the maven dependencies and compiling the source
#RUN wget -qO- https://mobicents.ci.cloudbees.com/job/RestComm-SMSC/lastSuccessfulBuild/artifact/smsc-version.txt -O version.txt && \
#mv version.txt /tmp/version && \
#wget -qc https://mobicents.ci.cloudbees.com/job/RestComm-SMSC/lastSuccessfulBuild/artifact/release/restcomm-smsc-`cat /tmp/version`.zip -O restcomm-smsc.zip && \
#unzip -qq restcomm-smsc.zip -d /opt/ && \

#rm -rf ${INSTALL_DIR}/jboss-5.1.0.GA/server/default && \
#mkdir -p ${INSTALL_DIR}/jboss-5.1.0.GA/server/simulator/log && \

RUN wget -qc https://github.com/RestComm/smscgateway/releases/download/7.2.109/restcomm-smsc-7.2.109.zip -O restcomm-smsc.zip && \
unzip -qq restcomm-smsc.zip -d /opt/ && \
mv /opt/restcomm-smsc-*/*/ ${INSTALL_DIR} && \
rm restcomm-smsc.zip && \
rm -rf ${INSTALL_DIR}/docs && \
rm -rf ${INSTALL_DIR}/cassandra/apache* && \
echo "SMSC verion: `cat /tmp/version`" > ${INSTALL_DIR}/version && \
mkdir -p ${INSTALL_DIR}/jboss-5.1.0.GA/server/default/log && \
`# making the downloaded jboss files executable` \
chmod +x ${INSTALL_DIR}/jboss-5.1.0.GA/bin/* && \
`# the entrypoint of phusion baseimage is rinit` \
chmod +x /etc/my_init.d/restcomm*.sh && \
chmod +x /tmp/.restcommenv.sh && \
`# attaching jboss log files to 'docker logs'` \
ln -sf /dev/stdout /opt/Restcomm-SMSC/version && \
ln -sf /dev/stdout /opt/Restcomm-SMSC/jboss-5.1.0.GA/server/default/log/server.log && \
ln -sf /dev/stdout /opt/Restcomm-SMSC/jboss-5.1.0.GA/server/default/log/boot.log

EXPOSE 8080 3435
