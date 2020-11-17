##Go to project directory and run the first command

>> docker build . -t otp-app-centos7

##After build successfully run the following command

>> docker run --privileged -d -it -e container=docker  -v /sys/fs/cgroup:/sys/fs/cgroup  otp-app-centos7 /usr/sbin/init

