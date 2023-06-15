#!/bin/bash

sed -i "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

rm /root/rclocal.sh
sed -i "s/.*sh /root/rclocal.sh.*//g" /etc/ssh/sshd_config

poweroff
