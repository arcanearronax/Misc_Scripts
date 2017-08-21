#!/bin/bash

#   Raspberry Pi Build Script
#   arronax - 08/19/2017
#   
#   Must run without sudo.

#Get our user's home directory
USR_DIR=`echo ~/`
echo $USR_DIR
cd $USR_DIR

# Welcome
echo "Welcome $USER."
SCR_USR=$USER
echo "Your Home Directory is $USR_DIR."
echo "Running config script..."
#sleep 1

# Need to enable SSH, user must do this for now
echo "User must enable SSH in GUI..."
#sleep 2
#sudo raspi-config

# Update stuff
echo "Update package manager..."
#sleep 2
#sudo apt-get update -y
#sudo apt-get upgrade -y

# Get vim configured
#echo "Install and Configure Vim..."
#sleep 2
#sudo apt-get install vim -y
#VIM_RC=$USR_DIR'.vimrc'
#echo $VIM_RC
#echo 'syntax on               " Enable color coding' >> $VIM_RC
#echo 'set tabstop=4           " \t has width 4' >> $VIM_RC
#echo 'set shiftwidth=4        " Indents have width of 4' >> $VIM_RC
#echo 'set softtabstop=4       " Set number of columns for \t' >> $VIM_RC
#echo 'set expandtab           " Expand \t to spaces' >> $VIM_RC

# Get Git configured
echo "Install and configure Git..."
#sleep 2
#sudo apt-get install git -y

#read -p "Please enter you Git username. Simply press Enter to skip this. " GIT_USR
#git config --global user.name "$GIT_USR"
echo "Username set: "
git config --global user.name

#read -p "Please enter your Git email. Simply press Enter to skip this. " GIT_EMA
#git config --global user.email "$GIT_EMA"
echo "Email set: "
git config --global user.email

# Enable key auth, assuming it's in place
echo "Enable SSH Key Auth for Git..."
#sleep 2
#SSH_CONF=$USR_DIR'.ssh/config'
#echo 'host github.com' >> $SSH_CONF
#echo '  HostName github.com' >> $SSH_CONF
#echo '  IdentityFile ~/.ssh/id_rsa' >> $SSH_CONF
#echo '  User git' >> $SSH_CONF

echo "Remember to clone your repos."
#sleep 2

# I like tree now that I know about it
echo "Installing Tree..."
#sleep 2
#sudo apt-get install tree -y

# Need to get MySQL
#sudo apt-get install mysql-server python-mysqldb mysql-client -y
# Need to set root password
#sleep 2
SQL_PID=`sudo cat /var/run/mysqld/mysqld.pid`
#echo "P_ID: $SQL_PID"
#sudo kill $SQL_PID
#echo "Create temp_conf here:"
#pwd
INIT_F=$USR_DIR'temp_conf.sql'
#echo "alter user 'root'@'localhost' identified by 'Chance1791';" >> $INIT_F
#echo "INIT_F = $INIT_F"
SU_SCR=$USR_DIR'.temp.sh'
#echo "mysqld --init-file=$INIT_F &" >> $SU_SCR
#sudo rm $INIT_F
#sudo chmod u+x $SU_SCR
#sudo su -c $SU_SCR
#echo 'Works?'
#sudo echo $SU_SCR
#sudo rm -f $SU_SCR
#sudo rm -f $INIT_F
# By this point root will be able to login to mysql

# Need to add a user for the person running the script
SQL_CNF=$USR_DIR'.sql_conf.sql'
#read -p "Enter a password for your MySQL localhost account: " SQL_PASS
#echo "grant all privileges on test.* to '$SCR_USR'@'localhost' identified by '$SQL_PASS';" >> $SQL_CNF
USR_DB="${SCR_USR}_database"
#echo "create database $USR_DB;" >> $SQL_CNF
#echo "grant all privileges on $USR_DB.* to '$SCR_USR'@'localhost' identified by '$SQL_PASS';" >> $SQL_CNF
#sudo mysql < $SQL_CNF
#sudo rm -f $SQL_CNF







# Any remaining changes need to be made
#reboot now
