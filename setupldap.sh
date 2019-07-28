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

sudo apt install apache2

# Must reconfigure slapd for it to work properly 
echo "check Point starts here"
sudo dpkg-reconfigure slapd
echo "check point ends here"

# Enable firewall rule
sudo ufw allow ldap

#sudo apt install apache2

# Populate LDAP
ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -w password -f basedn.ldif

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

echo $PASS

# Populate LDAP
ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -w password -f users.ldif 

# Test LDAP
ldapsearch -x -LLL -b dc=clemson,dc=cloudlab,dc=us 'uid=student' cn gidNumber
