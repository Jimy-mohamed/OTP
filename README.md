##You should first download the missed RPM package "oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm" from here:
https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html
After downloading, copy it the project directory

##Go to project directory and run the first command

>> docker build . -t otp-app-centos7

##After build successfully run the following command

>> docker run --privileged -d -it -e container=docker  -v /sys/fs/cgroup:/sys/fs/cgroup  otp-app-centos7 /usr/sbin/init




