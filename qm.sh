#!/bin/bash

GREEN='\033[0;32m' # GREEN
NC='\033[0m' # No Color

echo -n "Set VMID | (default: 1000): " ; read vmid
vmid=${vmid:-1000}
echo "${GREEN}Set VMID: $vmid${NC}"

echo -n "Set Name | (default: ubuntu): " ; read name
name=${name:-ubuntu}
echo "${GREEN}Set Name: $name${NC}"

echo -n "Set Core | (default: 1): " ; read core
core=${core:-1}
echo "${GREEN}Set Core: $core${NC}"

echo -n "Set Memory(MB) | (default: 1024): " ; read memory
memory=${memory:-1024}
echo "${GREEN}Set Memory(MB): $memory${NC}"

echo -n "Set Disk Size(MB) | (default: 10240): " ; read disksize
disksize=${disksize:-10240}
echo "${GREEN}Set Disk Size(MB): $disksize${NC}"

echo -n "Set Disk Name (sda|sdb) | (default: sda): " ; read diskname
diskname=${diskname:-sda}
echo "${GREEN}Set Disk Name (sda|sdb): $diskname${NC}"

echo -n "Set Disk Path | (default: /mnt/pve/${diskname}): " ; read diskpath
diskpath=${diskpath:-/mnt/pve/${diskname}}
echo "${GREEN}Set Disk Path: $diskpath${NC}"

echo -n "Set Bridge | (default: vmbr0): " ; read bridge
bridge=${bridge:-vmbr0}
echo "${GREEN}Set Bridge: $bridge${NC}"

read -p "Set IP Address (example: 10.0.10.123/24): " ipaddress
read -p "Set IP Gateway (example: 10.0.10.1): " ipgateway

read -p "Set Root Password: " rootpassword

echo "Choose Image Location:"
echo "1 | Local"
echo "2 | Download"

echo -n "Choose Cloud OS: " ; read n
case $n in
1)
echo "${GREEN}Local Image${NC}"
read -p "Set Image Path | (example: /mnt/pve/cloud/os.img): " imagepath
;;

2)
mkdir -p ${diskpath}/cloud/
echo "${GREEN}Download Cloud OS:${NC}"
echo "1 | Ubuntu 18.04 LTS"
echo "2 | Ubuntu 20.04 LTS"
echo "3 | Ubuntu 22.04 LTS"
echo "4 | Ubuntu 23.04"
echo "5 | CentOS 6"
echo "6 | CentOS 7"
echo "7 | CentOS 8 Stream"
echo "8 | CentOS 9 Stream"
echo "9 | Debian 9 (Buster)"
echo "10 | Debian 10 (buster)"
echo "11 | Debian 11 (bullseye)"
echo "12 | Debian 12 (bookworm)"

echo -n "Choose ${GREEN}Cloud OS:${NC} " ; read n
case $n in
1)
echo "Downloading ${GREEN}Ubuntu 18.04 LTS${NC}..."
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img -O ${diskpath}/cloud/download-os.img
;;

2)
echo "Downloading ${GREEN}Ubuntu 20.04 LTS${NC}..."
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img -O ${diskpath}/cloud/download-os.img
;;

3)
echo "Downloading ${GREEN}Ubuntu 22.04 LTS${NC}..."
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O ${diskpath}/cloud/download-os.img
;;

4)
echo "Downloading ${GREEN}Ubuntu 23.04${NC}..."
wget https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-amd64.img -O ${diskpath}/cloud/download-os.img
;;

5)
echo "Downloading ${GREEN}CentOS 6${NC}..."
wget https://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2 -O ${diskpath}/cloud/download-os.img
;;

6)
echo "Downloading ${GREEN}CentOS 7${NC}..."
wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2 -O ${diskpath}/cloud/download-os.img
;;

7)
echo "Downloading ${GREEN}CentOS 8 Stream${NC}..."
wget https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2 -O ${diskpath}/cloud/download-os.img
;;

8)
echo "Downloading ${GREEN}CentOS 9 Stream${NC}..."
wget https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2 -O ${diskpath}/cloud/download-os.img
;;

9)
echo "Downloading ${GREEN}Debian 9 (Buster)${NC}..."
wget https://cloud.debian.org/images/cloud/stretch/daily/20200210-166/debian-9-ec2-arm64-daily-20200210-166.tar.xz -O ${diskpath}/cloud/download-os.img
;;

10)
echo "Downloading ${GREEN}Debian 10 (buster)${NC}..."
wget https://cloud.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.qcow2 -O ${diskpath}/cloud/download-os.img
;;

11)
echo "Downloading ${GREEN}Debian 11 (bullseye)${NC}..."
wget https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2 -O ${diskpath}/cloud/download-os.img
;;

12)
echo "Downloading ${GREEN}Debian 12 (bookworm)${NC}..."
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2 -O ${diskpath}/cloud/download-os.img
;;

*) echo "invalid option";;
esac
imagepath=${diskpath}/cloud/download-os.img
echo "${GREEN}Image Path: $imagepath${NC}"
;;
*) echo "invalid option";;
esac

echo "Creating VM..."
echo "Stoping VMID ${GREEN}${vmid}${NC} (if exist)..."
qm stop ${vmid} > /dev/null 2>&1
echo "Destroying VMID ${GREEN}${vmid}${NC} (if exist)..."
qm destroy ${vmid} --purge > /dev/null 2>&1
echo "Setting VMID: ${GREEN}${vmid}${NC}"
qm create ${vmid} > /dev/null 2>&1
echo "Setting Name: ${GREEN}${name}${NC}"
qm set ${vmid} --name ${name} > /dev/null 2>&1
echo "Setting Core: ${GREEN}${core}${NC}"
qm set ${vmid} --cpu host > /dev/null 2>&1
qm set ${vmid} --core ${core} > /dev/null 2>&1
echo "Setting Memory: ${GREEN}${memory} MB${NC}"
qm set ${vmid} --memory ${memory} > /dev/null 2>&1
echo "Importing Disk Image..."
qm set ${vmid} --scsi0 ${diskname}:0,import-from=${imagepath} > /dev/null 2>&1
disksize_byte=$(stat -c %s ${diskpath}/images/${vmid}/vm-${vmid}-disk-0.raw)
disksize_megabyte=$(expr $disksize_byte / 1024 / 1024)
disksize_resize=$(expr ${disksize} - ${disksize_megabyte} - 1)
echo "Setting Disk Size: ${GREEN}${disksize} MB${NC}"
qm resize ${vmid} scsi0 +${disksize_resize}M > /dev/null 2>&1
qm resize ${vmid} scsi0 +1M > /dev/null 2>&1
echo "Setting Network..."
qm set ${vmid} --net0 e1000,bridge=${bridge} > /dev/null 2>&1
qm set ${vmid} --scsihw virtio-scsi-pci > /dev/null 2>&1
qm set ${vmid} --serial0 socket > /dev/null 2>&1
qm set ${vmid} --cicustom "user=${diskname}:snippets/cloud-init-${vmid}.yaml" > /dev/null 2>&1
echo "Setting Snippets..."
qm set ${vmid} --ide0 ${diskname}:cloudinit > /dev/null 2>&1
echo "#cloud-config" > ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo "runcmd:" >> ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo " - echo \"#!/bin/sh\" > /root/rclocal.sh" >> ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo " - echo \"curl https://raw.githubusercontent.com/tnan/proxmox/main/rclocal.sh | sh\" >> /root/rclocal.sh" >> ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo " - chmod +x /root/rclocal.sh" >> ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo " - echo \"#!/bin/sh\" > /etc/rc.local" >> ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo " - echo \"sh /root/rclocal.sh\" >> /etc/rc.local" >> ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo " - chmod +x /etc/rc.local" >> ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo " - systemctl enable rc-local" >> ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo " - poweroff" >> ${diskpath}/snippets/cloud-init-${vmid}.yaml
echo "Configuring Snippets..."
qm start ${vmid} > /dev/null 2>&1
vmstatus=$(qm status ${vmid})
while [ "$vmstatus" != "status: stopped" ]
do
vmstatus=$(qm status ${vmid}) > /dev/null 2>&1
done
sed -i "s/cicustom: user=${diskname}:snippets\/cloud-init-${vmid}.yaml//g" /etc/pve/qemu-server/${vmid}.conf
rm ${diskpath}/snippets/cloud-init-${vmid}.yaml
qm set ${vmid} --ciuser root > /dev/null 2>&1
qm set ${vmid} --cipassword ${rootpassword} > /dev/null 2>&1
qm set ${vmid} --ipconfig0 ip=${ipaddress},gw=${ipgateway} > /dev/null 2>&1
echo "Configuring Cloud-init..."
qm start ${vmid} > /dev/null 2>&1
vmstatus=$(qm status ${vmid})
while [ "$vmstatus" != "status: stopped" ]
do
vmstatus=$(qm status ${vmid}) > /dev/null 2>&1
done

echo "${GREEN}Done!${NC}"
