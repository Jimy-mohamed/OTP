FROM centos:7
MAINTAINER "Yourname" <youremail@address.com>
ENV container docker
RUN mkdir /root/packages
RUN yum -y update; yum clean all
RUN yum -y install systemd; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

#install_vsftpd
RUN yum update -y && yum install vsftpd -y
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
RUN /bin/bash -c 'chmod -R 777 /etc/vsftpd/vsftpd.conf'
RUN /bin/bash -c 'chown root:root /etc/vsftpd/vsftpd.conf'
ENTRYPOINT systemctl restart vsftpd

#install_ssh
RUN yum install openssh-server -y
COPY sshd_config /etc/ssh/sshd_config
RUN /bin/bash -c 'chmod -R 777 /etc/ssh/sshd_config'
RUN /bin/bash -c 'chown root:root /etc/vsftpd/vsftpd.conf'
ENTRYPOINT systemctl restart sshd

#install_apache
RUN yum install httpd -y
ENTRYPOINT	systemctl start httpd;\
		systemctl enable httpd
			
#install_firewall
RUN	yum install firewalld -y
ENTRYPOINT	systemctl start firewalld;\
		systemctl enable firewalld;\
		firewall-cmd --permanent --add-port=80/tcp;\
		firewall-cmd --permanent --add-port=443/tcp;\
		firewall-cmd --reload
			
#install_mysql
USER root
COPY mysql57-community-release-el7-9.noarch.rpm /root/packages
WORKDIR /root/packages
RUN /bin/bash -c 'chmod 777 mysql57-community-release-el7-9.noarch.rpm'
RUN rpm -ivh mysql57-community-release-el7-9.noarch.rpm
RUN yum install mysql-server -y
ENTRYPOINT 	systemctl start mysqld;\
		systemctl enable mysqld

#install_php
RUN yum install epel-release -y;\ 
    yum install utils -y;\
    yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm ;\
    yum-config-manager --enable remi-php73 ;\
    yum -y install php ;\
    yum -y install php-common ;\
    yum -y install php-opcache ;\
    yum -y install php-mcrypt ;\
    yum -y install php-cli ;\
    yum -y install php-gd ;\
    yum -y install php-curl ;\
    yum -y install php-mysqlnd ;\
    php -vs

#install_oracle_RPMs
COPY oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /root/packages
COPY oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /root/packages
COPY oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm /root/packages

RUN rpm -ivh oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm ;\
    rpm -ivh oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm ;\
    rpm -ivh oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm ;\
    ORACLE_HOME=/usr/lib/oracle/12.1/client64; export ORACLE_HOME ;\
    LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH ;\
    yum install alien -y;\
    yum install php-pear -y ;\
    yum install php-devel -y ;\
    pecl channel-update pecl.php.net ;\
    yum install systemtap-sdt-devel -y ;\
    export PHP_DTRACE=yes
WORKDIR	/usr/local/src
COPY oci8-2.1.3.tgz /usr/local/src
RUN tar zxvf oci8-2.1.3.tgz
WORKDIR /usr/local/src/oci8-2.1.3
RUN phpize ;\
    ./configure -with-oci8=shared,instantclient,/usr/lib/oracle/12.1/client64/lib/ ;\
    make install
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
