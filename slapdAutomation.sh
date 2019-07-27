#! /bin/bash

# Install openLDAP server quietly
export DEBIAN_FRONTEND=noninteractive

echo -e " 
slapd slapd/internal/generated_adminpw password password
slapd slapd/internal/adminpw password password
slapd slapd/password2 password password
slapd slapd/password1 password password
slapd slapd/root_password password password
slapd slapd/root_password_again password password
slapd slapd/domain string clemson.cloudlab.us
slapd shared/organization string clemson.cloudlab.us
slapd slapd/backend select MDB 
slapd slapd/purge_database boolean false
slapd slapd/move_old_database boolean true
slapd slapd/dump_database select when needed
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/invalid_config boolean true
" | sudo debconf-set-selections

sudo apt-get update

# Grab slapd and ldap-utils (pre-seeded)
sudo apt-get install -y slapd ldap-utils

# Must reconfigure slapd for it to work properly 
sudo dpkg-reconfigure slapd

# Enable firewall rule
sudo ufw allow ldap

# Populate LDAP
ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -w "password" -f basedn.ldif

# Generate password hash
PASS=$(slappasswd -s rammy)
cat <<EOF >/local/repository/users.ldif
dn: uid=student,ou=People,dc=clemson,dc=cloudlab,dc=us
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: student
sn: Ram
givenName: Golden
cn: student
displayName: student
uidNumber: 10000
gidNumber: 5000
userPassword: $PASS
gecos: Golden Ram
loginShell: /bin/dash
homeDirectory: /home/student
EOF

# Populate LDAP
ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -w "password" -f users.ldif 

# Test LDAP
ldapsearch -x -LLL -b dc=clemson,dc=cloudlab,dc=us 'uid=student' cn gidNumber

echo -e " 
ldap-auth-config        ldap-auth-config/rootbindpw     password password
ldap-auth-config        ldap-auth-config/bindpw password password
ldap-auth-config        ldap-auth-config/binddn string  cn=proxyuser,dc=example,dc=net
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/dblogin        boolean false
slapd   slapd/allow_ldap_v2     boolean false
libpam-runtime  libpam-runtime/profiles multiselect     unix, ldap, systemd, capability
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=clemson,dc=cloudlab,dc=us
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean true
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select  3
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=admin,dc=clemson,dc=cloudlab,dc=us
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldap://192.168.1.1
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean true
" | sudo debconf-set-selections

# Setup SSO on client
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
