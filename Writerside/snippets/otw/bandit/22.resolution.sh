#!/bin/bash

myname=$(whoami)
mytarget=$(echo I am user $myname | md5sum | cut -d ' ' -f 1)

echo "Copying passwordfile /etc/bandit_pass/$myname to /tmp/$mytarget"

cat /etc/bandit_pass/$myname > /tmp/$mytarget

echo I am user bandit23 | md5sum | cut -d ' ' -f 1 | awk '{ print "/tmp/" $1 }' | xargs cat