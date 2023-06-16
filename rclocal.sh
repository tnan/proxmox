#!/bin/bash

echo "curl -s https://raw.githubusercontent.com/tnan/proxmox/main/enable_root_ssh.sh | sh)" >> /etc/rc.local
chmod +x /etc/rc.local
systemctl enable rc-local
reboot
