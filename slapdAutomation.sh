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

BASE    dc=clemson,dc=cloudlab,dc=us
URI     ldap://192.68.1.1 ldap://192.68.1.1:666

sudo apt-get update

# Grab slapd and ldap-utils (pre-seeded)
sudo apt-get install -y slapd ldap-utils

# Must reconfigure slapd for it to work properly 
sudo dpkg-reconfigure slapd

# Enable firewall rule
sudo ufw allow ldap

sudo apt-get install expect
sudo apt-get install expect-dev

# Populate LDAP
ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -w "password" -f basedn.ldif

# Generate password hash
slappasswd -h {SSHA} -s rammy

# Populate LDAP
ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -w "password" -f users.ldif 

# Test LDAP
ldapsearch -x -LLL -b dc=clemson,dc=cloudlab,dc=us 'uid=student' cn gidNumber

# Setup SSO on client
sudo apt-get update
sudo apt install -y libnss-ldap -y libpam-ldap ldap-utils
