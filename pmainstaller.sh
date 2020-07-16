#!/usr/bin/bash

cd ~

install=1
remove=0
force=0

while getopts 'fu' flag; do
  case "${flag}" in
    f) force=1 ;;
    u) remove=1; install=0 ;;
    *) echo "Unknown flag"
       exit 1 ;;
  esac
done

install_dest="/var/www/html/pma"
my_user="3wroot"

function install
{
	cd ~
	echo "install starting"
	
	if [ -d "${install_dest}" ]; then
		echo "PhpMyAdmin is already installed in ${install_dest}, exiting"
		exit 0
	fi 
	
	while true; do
	    read -s -p "MySql Password: " password
	    echo
	    read -s -p "MySql Password (Confirm): " password2
	    echo
	    [ "$password" = "$password2" ] && break || echo "Please try again"
	done
	
	if [ ! -d ~/pmainstaller/ ]; then
		echo "no dir pma installer"
		mkdir pmainstaller
	fi
	
	my_pass=$password

	cd ./pmainstaller
	wget wget https://files.phpmyadmin.net/phpMyAdmin/4.9.5/phpMyAdmin-4.9.5-english.tar.gz
	tar xvzf ./phpMyAdmin-4.9.5-english.tar.gz
	rm -f ./phpMyAdmin-4.9.5-english.tar.gz
	mv ./phpMyAdmin-4.9.5-english $install_dest
	
	cd ~
	rm -rf ./pmainstaller
	
	mysql <<MYQUERY
CREATE USER '${my_user}'@'localhost' IDENTIFIED BY '${my_pass}';
GRANT ALL PRIVILEGES ON *.* TO '${my_user}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYQUERY
}

function uninstall
{
	echo "uninstall executed."
	if [ ! -d "${install_dest}" ]; then
		echo "PhpMyAdmin is not installed in ${install_dest}, exiting"
		exit 0
	fi 
	
	echo "PhpMyAdmin Installation found"
	
	while true; do
	    read -p "Do you wish to uninstall PhpMyAdmin? " yn
	    case $yn in
	        [Yy]* ) echo "Hello removing everything"; break;;
	        [Nn]* ) exit;;
	        * ) echo "Please answer Y or N." ;;
	    esac
	done
	
	
	
	echo "removing files"
	rm -rf $install_dest
	echo "removing MySql User ${my_user}"
	mysql <<MYQUERY
DROP USER '${my_user}'@'localhost';
FLUSH PRIVILEGES;
MYQUERY
	echo "Finsihed removal of PhpMyAdmin"
	
}

if [ $remove == 1 ]; then
	uninstall
fi

if [ $install == 1 ]; then
	install
fi
