#! /bin/bash


export DEBIAN_FRONTEND=noninteractive


sudo apt-get update
sudo apt install -y libnss-ldapd -y libpam-ldap ldap-utils

# Provide hostname of node in the ldap.conf file
sudo sed -i 's|ldapi:///|ldap://192.168.1.1|g' /etc/ldap.conf

# Enable LDAP profile for NSS
sudo sed -i 's/systemd/systemd ldap/g' /etc/nsswitch.conf

# Enable LDAP profile PAM
sudo sed -i 's/\<use_authtok\>//g' /etc/pam.d/common-password
sudo sed -i '31 a session optional        pam_mkhomedir.so skel=/etc/skel umask=077' /etc/pam.d/common-session

# Authenticate student user on ldapclient
getent passwd student

# Login as student user
sudo su - student
