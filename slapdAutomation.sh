#! /bin/bash
export DEBIAN_FRONTEND=noninteractive

echo -e " 
slapd    slapd/internal/generated_adminpw password password
slapd    slapd/password2    password    openstack
slapd    slapd/internal/adminpw    password openstack
slapd    slapd/password1    password    openstack
" | sudo debconf-set-selections

sudo apt-get install -y slapd ldap-utils
