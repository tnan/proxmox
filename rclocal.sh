#!/bin/bash

sed -i 's/.*disable_root.*/disable_root: false/g' /etc/cloud/cloud.cfg
sed -i 's/.*ssh_pwauth.*/ssh_pwauth: true/g' /etc/cloud/cloud.cfg

sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/.*PubkeyAuthentication.*/PubkeyAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/.*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/.*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config

echo "" > /etc/rc.local
rm /root/rclocal.sh
systemctl disable rc-local

poweroff
