FROM phusion/baseimage:latest

#MAINTAINER TBD

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_DIR /opt/Restcomm-SMSC

# this docker holds the jboss of SMSC and the initial db scripts, so it installs first the db client (cqlsh) and java 7.
# Some of the other dependencies are dependencies of restcomm-connect and not necessarily of SMSC
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true |  /usr/bin/debconf-set-selections && \
locale-gen en_US en_US.UTF-8 && \
dpkg-reconfigure locales && \
add-apt-repository ppa:webupd8team/java -y && \
apt-cache search mysql-client-core && \
apt-get update && \
apt-get install -y \
screen wget ipcalc bsdtar oracle-java7-installer \
mysql-client-core-5.7 openssl unzip nfs-common tcpdump dnsutils net-tools \
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
rm restcomm-smsc.zip

RUN ls -la ${INSTALL_DIR}
RUN chmod +x ${INSTALL_DIR}/jboss-5.1.0.GA/bin/*
RUN mkdir -p ${INSTALL_DIR}/jboss-5.1.0.GA/server/simulator/log
ENV jboss.server.name simulator

# scripts common to all restcomm dockers
RUN mkdir -p /opt/embed/

ADD ./ca-startcom.der ${INSTALL_DIR}/jboss-5.1.0.GA/ca-startcom.der
ADD ./cron_files/tcpdump_crontab /etc/cron.d/restcommtcpdump-cron
ADD ./cron_files/core_crontab /etc/cron.d/restcommcore-cron
ADD ./cron_files/mediaserver_crontab /etc/cron.d/restcommmediaserver-cron
ADD ./scripts/dockercleanup.sh /opt/embed/dockercleanup.sh
ADD ./scripts/docker_do.sh   /opt/embed/restcomm_docker.sh

RUN mkdir -p /etc/my_init.d

ADD ./scripts/automate_conf.sh /etc/my_init.d/restcommautomate.sh
ADD ./scripts/restcomm_setenv.sh /tmp/.restcommenv.sh
ADD ./scripts/restcomm_conf.sh /etc/my_init.d/restcommconf.sh
ADD ./scripts/restcomm_sslconf.sh /etc/my_init.d/restcommsslconf.sh
ADD ./scripts/restcomm_toolsconf.sh /etc/my_init.d/restcommtoolsconf.sh
ADD ./scripts/restcomm_support_load_balancer.sh /etc/my_init.d/restcommtoolsconf_loadbalancer.sh

# the entrypoint is init and this is the main script
ADD ./scripts/restcomm_smsc_service.sh /tmp/restcomm_service.sh
RUN chmod +x /etc/my_init.d/restcomm*.sh
RUN chmod +x /tmp/.restcommenv.sh

# attaching files to 'docker logs'
RUN mkdir -p /opt/Restcomm-SMSC/jboss-5.1.0.GA/server/simulator/log
RUN touch /opt/Restcomm-SMSC/jboss-5.1.0.GA/server/simulator/log/server.log 
RUN touch /opt/Restcomm-SMSC/jboss-5.1.0.GA/server/simulator/log/boot.log 
RUN ln -sf /dev/stdout /opt/Restcomm-SMSC/jboss-5.1.0.GA/server/simulator/log/server.log
RUN ln -sf /dev/stdout /opt/Restcomm-SMSC/jboss-5.1.0.GA/server/simulator/log/boot.log

EXPOSE 8080 
