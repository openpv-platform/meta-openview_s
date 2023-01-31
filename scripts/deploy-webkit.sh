#!/bin/bash -

# Run this script in the same directory as the webkit tarball
# Assumes standard IP connection to rcd

ssh-keygen -R 192.168.7.1
ssh -t root@192.168.7.1 'mkdir -p /usr/local/webkit/'
scp webkit.tar root@192.168.7.1:/usr/local/webkit/
ssh -t root@192.168.7.1 'cd /usr/local/webkit/ && tar -xf webkit.tar'
ssh -t root@192.168.7.1 'cd /usr/local/webkit/ && apt install ./*.deb'
