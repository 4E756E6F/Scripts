#!/bin/bash

ADMUSER=""
DOMAIN=""
NUMBER=""

while getopts "u:d:n;" opt; do
    case $opt in
        u) ADMUSER="$OPTARG" ;;
        d) DOMAIN="$OPTARG" ;;
        n) NUMBER="$OPTARG" ;;
        \?) echo "Usage: $0 -u <domain admin account> -d <domain you want to join> -n <number of users to have access to the machine (integer)>" >&2; exit 1 ;;
    esac
done

#** Thinking of getting rid of this
read -p "Would you like to update the system before proceeding? (y/n):" update
if $update == "y"; then
    sudo apt update
    sudo apt-get full-upgrade -y
    apt-get autoremove -y
else
    return 0
fi

echo "Tell me the usernames, that should have access tot he machine:"
for ((i=1; i<=NUMBER; i++)); do
    read -p "Username #$i: " username
    
    if [[ -z "$usernames" ]]; then
        usernames="$username"
    else
        usernames="$usernames, $username"
    fi
done


sudo apt update
apt-get install -y sssd-ad sssd-tools realmd adcli
sudo realm -v discover $DOMAIN
sudo realm -v join $DOMAIN -u $admuser

cat <<EOF > /etc/sssd/sssd.conf
[sssd]
domains = $DOMAIN
config_file_version = 2
services = nss, pam
	
[domain/$DOMAIN]
default_shell = /bin/bash
krb5_store_password_if_offline = True
cache_credentials = True
krb5_realm = $DOMAIN
realmd_tags = manages-system joined-with-adcli 
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = $DOMAIN
use_fully_qualified_names = True
ldap_id_mapping = True
access_provider = ad
#!! KEYS ON TEXT
EOF

sudo pam-auth-update --enable mkhomedir
