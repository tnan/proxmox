#!/bin/bash

read -p "Set VMID: " vmid
read -p "Set Name: " name
read -p "Set Core: " core
read -p "set Memory (MB): " memory
read -p "Set Disk Size (MB): " disksize
read -p "Set Disk Name (example: sda|sdb): " diskname
read -p "Set Disk Location (example: /mnt/pve/sda): " disklocation
read -p "Set Image Path (img): " imagepath
read -p "Set IP Address (example: 10.0.10.123/24): " ipaddress
read -p "Set IP Gateway (example: 10.0.10.1): " ipgateway
read -p "Set Root Password: " rootpassword
echo "Creating VM..."
echo "Stoping VMID ${vmid} (if exist)..."
qm stop ${vmid} > /dev/null 2>&1
echo "Destroying VMID ${vmid} (if exist)..."
qm destroy ${vmid} --purge >/dev/null 2>&1
echo "Setting VMID: ${vmid}"
qm create ${vmid} > /dev/null 2>&1
echo "Setting Name: ${name}"
qm set ${vmid} --name ${name} > /dev/null 2>&1
echo "Setting Core: ${core}"
qm set ${vmid} --cpu host > /dev/null 2>&1
qm set ${vmid} --core ${core} > /dev/null 2>&1
echo "Setting Memory: ${memory} MB"
qm set ${vmid} --memory ${memory} > /dev/null 2>&1
echo "Setting Cloud-init..."
qm set ${vmid} --ide0 ${diskname}:cloudinit > /dev/null 2>&1
echo '#cloud-config' > ${disklocation}/snippets/cloud-init.yaml
echo 'user: root' >> ${disklocation}/snippets/cloud-init.yaml
echo "password: ${rootpassword}" >> ${disklocation}/snippets/cloud-init.yaml
echo 'chpasswd:' >> ${disklocation}/snippets/cloud-init.yaml
echo 'expire: False' >> ${disklocation}/snippets/cloud-init.yaml
echo 'ssh_pwauth: True' >> ${disklocation}/snippets/cloud-init.yaml
echo 'disable_root: False' >> ${disklocation}/snippets/cloud-init.yaml
echo "Setting Network..."
qm set ${vmid} --net0 e1000,bridge=vmbr0 > /dev/null 2>&1
qm set ${vmid} --scsihw virtio-scsi-pci > /dev/null 2>&1
qm set ${vmid} --cicustom "user=${diskname}:snippets/cloud-init.yaml" > /dev/null 2>&1
echo "Importing Disk Image..."
qm set ${vmid} --sata0 ${diskname}:0,import-from=${imagepath} > /dev/null 2>&1
disksize_byte=$(stat -c %s ${disklocation}/images/${vmid}/vm-${vmid}-disk-0.raw)
disksize_megabyte=$(expr $disksize_byte / 1024 / 1024)
disksize_resize=$(expr ${disksize} - ${disksize_megabyte})
echo "Setting Disk Size: ${disksize} MB"
qm resize ${vmid} sata0 +${disksize_resize}M > /dev/null
echo "Done!"
