## 1. /etc/ssh/sshd_config
* Port 22
* Port 3000
* PermitRootLogin yes
* PasswordAuthentication yes

## 2. /root/.ssh/authorized_keys
* mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys.old

## 3. refresh sshd
* systemctl restart sshd

## 4. selinux off
* setenforce 0
* Modify /etc/selinux/config
    * SELUNUX=disabled

