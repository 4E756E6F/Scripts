sudo apt update
sudo apt-get full-upgrade -y
apt-get autoremove -y

apt-get install -y sssd-ad sssd-tools realmd adcli
sudo realm -v discover $domain
sudo realm -v join ad1.example.com -u $admuser

cat <<EOF > /etc/sssd/sssd.conf
[sssd]
domains = ad1.example.com
config_file_version = 2
services = nss, pam
	
[domain/$domain]
default_shell = /bin/bash
krb5_store_password_if_offline = True
cache_credentials = True
krb5_realm = AD1.EXAMPLE.COM
realmd_tags = manages-system joined-with-adcli 
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = $domain
use_fully_qualified_names = True
ldap_id_mapping = True
access_provider = ad