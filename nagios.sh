echo """The propose of this script is to install Nagios Core for you on a Ubuntu machine."""
echo "So lets get started"
sleep 2
echo "[INFO] Installing Prerequisites"
sleep 2
sudo apt-get update
sudo apt-get install -y wget build-essential unzip openssl libssl-dev apache2 php libapache2-mod-php php-gd libgd-dev
sudo apt-get autoremove -y
echo "[INFO] Creating Nagios user"
sudo adduser nagios
sudo usermod -a -G nagcmd nagios
sudo usermod -a -G nagcmd www-data
echo "[INFO]  Installing Nagios Core Service"
cd /opt/
sudo wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
sudo tar -xvf nagios-4.4.6.tar.gz
cd nagios-4.4.6
sudo ./configure --with-command-group=nagcmd
sudo make all
sudo make install
sudo make install-init
sudo make install-daemoninit
sudo make install-config
sudo make install-commandmode
sudo make install-exfoliation
cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
echo "[INFO] Setting up Apache with Authentication"
sudo cat >> /etc/apache2/conf-available/nagios.conf << EOL
ScriptAlias /nagios/cgi-bin "/usr/local/nagios/sbin"

<Directory "/usr/local/nagios/sbin">
   Options ExecCGI
   AllowOverride None
   Order allow,deny
   Allow from all
   AuthName "Restricted Area"
   AuthType Basic
   AuthUserFile /usr/local/nagios/etc/htpasswd.users
   Require valid-user
</Directory>

Alias /nagios "/usr/local/nagios/share"

<Directory "/usr/local/nagios/share">
   Options None
   AllowOverride None
   Order allow,deny
   Allow from all
   AuthName "Restricted Area"
   AuthType Basic
   AuthUserFile /usr/local/nagios/etc/htpasswd.users
   Require valid-user
</Directory>
EOL
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
sudo a2enconf nagios
sudo a2enmod cgi rewrite
sudo service apache2 restart
echo "[INFO] Installing Nagios Plugins"
cd /opt
sudo wget http://www.nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
sudo tar -xvf nagios-plugins-2.2.1.tar.gz
cd nagios-plugins-2.2.1
sudo ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
sudo make
sudo make install
echo "[INFO] Verifing Settings"
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sudo systemctl start nagios
sudo systemctl enable nagios
echo 'ALL DONE!!!'
echo 'To access nagios just go to your browser and enter the dashboard via: http://localhost/nagios'