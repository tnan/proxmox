#!/bin/bash

read -p "Set VMID: " vmid
read -p "Set Name: " name
read -p "Set Core: " core
read -p "set Memory(MB): " memory
read -p "Set Disk (sda|sdb): " disk
read -p "Set Disk Size(MB): " disksize
read -p "Set Image Path: " path
echo "Creating VM..."
qm stop ${vmid} > /dev/null 2>&1
echo "Stoping VMID ${vmid} (if exist)..."
qm destroy ${vmid} --purge >/dev/null 2>&1
echo "Destroying VMID ${vmid} (if exist)..."
qm create ${vmid} > /dev/null 2>&1
echo "Setting VMID: ${vmid}"
qm set ${vmid} --name ${name} > /dev/null 2>&1
echo "Setting Name: ${name}"
qm set ${vmid} --cpu host > /dev/null 2>&1
qm set ${vmid} --core ${core} > /dev/null 2>&1
echo "Setting Core: ${core}"
qm set ${vmid} --memory ${memory} > /dev/null 2>&1
echo "Setting Memory: ${memory} MB"
qm set ${vmid} --net0 e1000,bridge=vmbr0 > /dev/null 2>&1
qm set ${vmid} --scsihw virtio-scsi-pci > /dev/null 2>&1
qm set ${vmid} --ide0 ${disk}:cloudinit > /dev/null 2>&1
qm set ${vmid} --sata0 ${disk}:0,import-from=${path} > /dev/null 2>&1
disksize_byte=$(stat -c %s /mnt/pve/${disk}/images/${vmid}/vm-${vmid}-disk-0.raw)
disksize_megabyte=$(expr $disksize_byte / 1024 / 1024)
disksize_resize=$(expr ${disksize} - ${disksize_megabyte})
qm resize ${vmid} sata0 +${disksize_resize}M > /dev/null
echo "Done!"
