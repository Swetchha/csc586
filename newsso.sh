#! /bin/bash

echo -e " 
ldap-auth-config        ldap-auth-config/rootbindpw     password abcd123
ldap-auth-config        ldap-auth-config/bindpw password abcd123
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/binddn string  cn=proxyuser,dc=example,dc=net
ldap-auth-config        ldap-auth-config/dblogin        boolean false
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=clemson,dc=cloudlab,dc=us
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean true
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select  3
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=admin,dc=clemson,dc=cloudlab,dc=us
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldap://192.168.1.1
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean true
" | sudo debconf-set-selections


#sudo apt-get update
sudo apt install -y libnss-ldapd -y libpam-ldap ldap-utils

# Provide hostname of node in the ldap.conf file
sudo sed -i 's|ldapi:///|ldap://192.168.1.1|g' /etc/ldap.conf
#chmod 777 /etc/ldap.conf

# Enable LDAP profile for NSS
sudo sed -i 's/systemd/systemd ldap/g' /etc/nsswitch.conf
#chmod 777 /etc/nsswitch.conf

# Enable LDAP profile PAM
sudo sed -i 's/\<use_authtok\>//g' /etc/pam.d/common-password
#chmod 777 /etc/pam.d/common-password
sudo sed -i '31 a session optional        pam_mkhomedir.so skel=/etc/skel umask=077' /etc/pam.d/common-session
#chmod 777 /etc/pam.d/common-session

# Authenticate student user on ldapclient
getent passwd student

# Login as student user
sudo su - student
