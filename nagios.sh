figlet NAGIOS
echo
echo """The propose of this script is to install Nagios Core for you on a CentOS machine."""
echo "So lets get started"
echo "It's recommended to run this script as a superuser, are you a superuser?? (y/n)"
read awnser
if (($awnser == 'n'))
then
    su root
    break
else
    break
fi
echo "[INFO] Installing LAMP stack"
sleep 2
dnf install -y httpd mariadb-server php-mysqlnd php-fpm
systemctl start httpd
systemctl enable httpd
systemctl status httpd
sleep 5
systemctl start mariadb
systemctl enable mariadb
systemctl status mariadb
sleep 5
echo "!!! YOUR INPUT IS REQUIRED !!!"
echo """If you never configured mysql just simple press enter when prompt to insert the root password,
as there's none.. Then just simple awnser the questions"""
sleep 10
mysql_secure_installation
echo "[INFO] Installing Install Required packages"
sleep 2
dnf install -y gcc glibc glibc-common wget gd gd-devel perl postfix
echo "[INFO] Creating a Nagios user account"
sleep 2
adduser nagios
echo ''
echo 'CREATE NAGIOS USER PASSWORD'
echo ''
passwd nagios
groupadd nagioscore
usermod -aG nagioscore nagios
usermod -aG nagioscore apache
echo '[INFO] Download and install Nagios Core'
sleep 2
cd /tmp
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
tar -xvf nagios-4.4.6.tar.gz
rm -rf nagios-4.4.6.tar.gz
cd nagios-4.4.6
./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-daemoninit
make install-config
make install-commandmode
make install-exfoliation
make install-webconf
echo '[INFO] Configure APACHE web server authentuication'
echo 'CREATE NAGIOSADMIN USER PASSWORD'
sleep 2
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
systemctl restart httpd
cd ..
echo '[INFO] Download and install nagios Plugins'
sleep 2
wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar -xvf nagios-plugins-2.3.3
rm -rf nagios-plugins-2.3.3
cd nagios-plugins-2.3.3
./configure --with-nagios-user=nagios --with-nagios-group=nagioscore
makemake install
echo '[INFO] Verify and start nagios'
sleep 2
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sleep 5
systemctl start nagios
systemctl status nagios
firewall-cmd --permanet --add-port=80/tcp
firewall-cmd --reload
echo 'ALL DONE!!!'
echo 'To access nagios just go to your browser and enter the dashboard via: http://localhost/nagios'