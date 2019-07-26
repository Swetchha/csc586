#! /bin/bash

#Install openLDAP server quietly
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
apt-get install -y slapd ldap-utils phpldapadmin

# Must reconfigure slapd for it to work properly 
sudo dpkg-reconfigure slapd

# Enable firewall rule
sudo ufw allow ldap

