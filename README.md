# OTP
This is for test
docker build . -t otp-centos7
docker run --privileged -d -it -e container=docker  -v /sys/fs/cgroup:/sys/fs/cgroup  otp-centos7 /usr/sbin/init
