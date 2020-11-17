docker build . -t otp-app-centos7

docker run --privileged -d -it -e container=docker  -v /sys/fs/cgroup:/sys/fs/cgroup  otp-app-centos7 /usr/sbin/init
