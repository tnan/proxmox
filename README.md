Resize VG0 root
```
lvresize -l +100%FREE /dev/vg0/root && resize2fs /dev/vg0/root
```
Install Webmin
```
wget https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh && printf 'y\n' | sh setup-repos.sh && apt-get install -y webmin --install-recommends
```
QM Setup script
```
wget -O qm.sh https://github.com/tnan/proxmox/raw/main/qm.sh && sh qm.sh
```

NAT Network
```
auto vmbr1
iface vmbr1 inet static
        address 10.10.10.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0

    post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
    post-up   iptables -t nat -A POSTROUTING -s '10.10.10.0/24' -o eno1 -j MASQUERADE
    post-down iptables -t nat -D POSTROUTING -s '10.10.10.0/24' -o eno1 -j MASQUERADE
    post-up   iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1  
    post-down iptables -t raw -D PREROUTING -i fwbr+ -j CT --zone 1
```
