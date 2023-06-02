#!/bin/bash

RED='\033[0;32m' # Red
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

*) echo "invalid option";;
esac
imagepath=${diskpath}/cloud/download-os.img
echo "${GREEN}Image Path: $imagepath${NC}"
;;
*) echo "invalid option";;
esac

echo "Creating VM..."
qm stop ${vmid}
echo "Stoping VMID ${vmid} (if exist)..."
qm destroy ${vmid} --purge
echo "Destroying VMID ${vmid} (if exist)..."
qm create ${vmid}
echo "Setting VMID: ${vmid}"
qm set ${vmid} --name ${name}
echo "Setting Name: ${name}"
qm set ${vmid} --cpu host
qm set ${vmid} --core ${core}
echo "Setting Core: ${core}"
qm set ${vmid} --memory ${memory}
echo "Setting Memory: ${memory} MB"
qm set ${vmid} --net0 e1000,bridge=vmbr0
qm set ${vmid} --scsihw virtio-scsi-pci
qm set ${vmid} --ide0 ${diskname}:cloudinit
qm set ${vmid} --sata0 ${diskname}:0,import-from=${imagepath}
disksize_byte=$(stat -c %s ${diskpath}/images/${vmid}/vm-${vmid}-disk-0.raw)
disksize_megabyte=$(expr $disksize_byte / 1024 / 1024)
disksize_resize=$(expr ${disksize} - ${disksize_megabyte})
qm resize ${vmid} sata0 +${disksize_resize}M
echo "Done!"
