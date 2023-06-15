#!/bin/bash
sleep 10

sed -i "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*ssh_pwauth.*/ssh_pwauth: true/" /etc/cloud/cloud.cfg
sed -i "s/.*disable_root.*/disable_root: false/g" /etc/cloud/cloud.cfg

poweroff
