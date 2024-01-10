Install Webmin
```
wget https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh && printf 'y\n' | sh setup-repos.sh && apt-get install -y webmin --install-recommends
```
```
lvresize -l +100%FREE /dev/vg0/root && resize2fs /dev/vg0/root
```
