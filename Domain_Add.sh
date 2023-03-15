#!/bin/bash

echo "This script will help you to add a Linux based OS to your Windows Active Directory domain"
echo """With the release of Ubuntu 20.04 and Debian 11 the
method to add a pc, running one of this OS,
to a Windows Active Diretory domain as changed..
So with this in mind let me now witch one are you using"""
sleep 4
echo ""
echo ""
echo "If you're using Ubuntu < 20.04 or Debian < 11"
echo "Type 0"
echo "If you're using Ubuntu >= 20.04 or Debian >= 11"
echo "Type 1"
read OS
sleep 2
echo ""
echo "What's your domain??"
read Domain
echo "What's your user??"
read User
echo ""
echo ""
echo ""
echo "########################################################"
echo "#                                                      #"
echo "#                                                      #"
echo "#                                                      #"
echo "#       ⨻⨻ THIS SCRIPT UPGRADES YOUR SYSTEM ⨻⨻       #"
echo "#                                                      #"
echo "#                                                      #"
echo "#                                                      #"
echo "########################################################"
sleep 6
if [ $OS == 0 ]; then
    sudo apt-get install -y ssh
    wget http://download.beyondtrust.com/PBISO/8.0.1/linux.deb.x64/pbis-open-8.0.1.2029.linux.x86_64.deb.sh
    sudo chmod +x pbis-open-8.0.1.2029.linux.x86_64.deb.sh
    sudo ./pbis-open-8.0.1.2029.linux.x86_64.deb.sh
    sudo apt update
    sudo apt upgrade
    sudo domainjoin-cli join $Domain $User
    sudo /opt/pbis/bin/config UserDomainPrefix $Domain
    sudo /opt/pbis/bin/config AssumeDefaultDomain True
    sudo /opt/pbis/bin/config LoginShellTemplate /bin/bash
    sudo /opt/pbis/bin/config HomeDirTemplate %H/%D/%U
    sudo rm pbis-open-8.0.1.2029.linux.x86_64.deb.sh
    sudo rm -r pbis-open-8.0.1.2029.linux.x86_64.deb/
    domainjoin-cli query
elif [ $OS == 1 ]; then
    sudo apt install -y ssh
    sudo wget https://github.com/BeyondTrust/pbis-open/releases/download/9.1.0/pbis-open-9.1.0.551.linux.x86_64.deb.sh --no-check-certificate
    sudo chmod +x pbis-open-9.1.0.551.linux.x86_64.deb.sh
    sudo ./pbis-open-9.1.0.551.linux.x86_64.deb.sh
    sudo apt update
    sudo apt upgrade
    sudo domainjoin-cli join $Domain $User
    sudo /opt/pbis/bin/config UserDomainPrefix $Domain
    sudo /opt/pbis/bin/config AssumeDefaultDomain Tru
    sudo /opt/pbis/bin/config LoginShellTemplate /bin/bash
    sudo /opt/pbis/bin/config HomeDirTemplate %H/%D/%U
    sudo rm pbis-open-9.1.0.551.linux.x86_64.deb.sh
    sudo rm -r pbis-open-9.1.0.551.linux.x86_64.deb/
    domainjoin-cli query
else
    echo ""
    echo "404 Option not found"
    break
fi
