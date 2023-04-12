#!/bin/bash
hypen=

read -p "Set VMID: " vmid
read -p "Set Name (hostname): " name
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
echo 'bootcmd:' >> ${disklocation}/snippets/cloud-init.yaml
echo " - sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config" >> ${disklocation}/snippets/cloud-init.yaml
echo " - sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/g' /etc/ssh/sshd_config" >> ${disklocation}/snippets/cloud-init.yaml
echo " - sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config" >> ${disklocation}/snippets/cloud-init.yaml
echo " - history -c" >> ${disklocation}/snippets/cloud-init.yaml
echo " - poweroff" >> ${disklocation}/snippets/cloud-init.yaml
echo "Setting Network..."
qm set ${vmid} --net0 e1000,bridge=vmbr0 > /dev/null 2>&1
qm set ${vmid} --scsihw virtio-scsi-pci > /dev/null 2>&1
qm set ${vmid} --cicustom "user=${diskname}:snippets/cloud-init.yaml" > /dev/null 2>&1
echo "Importing Disk Image..."
qm set ${vmid} --sata0 ${diskname}:0,import-from=${imagepath} > /dev/null 2>&1
disksize_byte=$(stat -c %s ${disklocation}/images/${vmid}/vm-${vmid}-disk-0.raw)
disksize_megabyte=$(expr $disksize_byte / 1024 / 1024)
disksize_resize=$(expr ${disksize} - ${disksize_megabyte} - 1)
echo "Setting Disk Size: ${disksize} MB"
qm resize ${vmid} sata0 +${disksize_resize}M > /dev/null 2>&1
qm resize ${vmid} sata0 +1M > /dev/null 2>&1
echo "Configuring Snippets..."
qm start ${vmid} > /dev/null 2>&1
vmstatus=$(qm status ${vmid})
while [ "$vmstatus" != "status: stopped" ]
do
vmstatus=$(qm status ${vmid}) > /dev/null 2>&1
done
sed -i "s/cicustom: user=${diskname}:snippets\/cloud-init.yaml//g" /etc/pve/qemu-server/${vmid}.conf
rm ${disklocation}/snippets/cloud-init.yaml
echo "Setting Config..."
qm set ${vmid} --ciuser root > /dev/null 2>&1
qm set ${vmid} --cipassword ${rootpassword} > /dev/null 2>&1
qm set ${vmid} --ipconfig0 ip=${ipaddress},gw=${ipgateway} > /dev/null 2>&1
echo "Done!"
