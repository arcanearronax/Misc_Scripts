#!/bin/bash

#   System Build Script
#   arronax - 01/19/2019
#
#   Must run without sudo.

#   Reworking this a bit
#

# Get our script parameters
while test ${#} -gt 0; do
    case $1 in
        --pub)
          SSH_PUB="$2"
          shift
          shift
          ;;
        --priv)
          SSH_PRIV="$2"
          shift
          shift
          ;;
        *)
          echo "ARG: $1 is unknown. Exiting Script."
          exit 1
          ;;
    esac
done

echo "$SSH_PUB"
echo "$SSH_PRIV"


# Get info about the environment for vars
OS_NAME=`cat /etc/*-release | grep -m1 NAME | awk -F '[=]' '{print $2}'`
echo $OS_NAME
# Possible Values:
# Fedora
# Raspbian GNU/Linux
# Ubuntu

if [ "$OS_NAME" == "" ]; then
  echo "Could not retrieve OS_NAME."
  exit 0
fi

# Package manager updates
if [ "$OS_NAME" == "Fedora" ]; then
  sudo dnf update -y 2&>1
  sudo dnf upgrade -f 2&>1
  echo "DNF Update"
else if [ "$OS_NAME" == "Raspbian GNU/Linux" ]; then
  sudo apt-get update -y 2&>1
  sudo apt-get upgrade -y 2&>1
  echo "APT Update"
else if [ "$OS_NAME" == "Ubuntu" ]; then
  sudo apt-get update -y 2&>1
  sudo apt-get upgrade -y 2&>1
  echo "APT Update"
fi

# Add bash aliases
if [ "$OS_NAME" != "Raspbian GNU/Linux" ]; then
  echo "alias gopi='ssh arronax@10.0.0.5'" >> ~/.bashrc
  echo "alias la='ls -ulta'" >> ~/.bashrc
  echo "alias vpnic='/home/arronax/bin/CG_IC 2&>1'"
  . ~/.bashrc
fi

# Setup SSH config

# Update vim









exit 1

#
# Keep everything below here until it's updated above
#

# Get the user's base information
USR_DIR=$HOME
#   Running as ./System_Build -y will bypass continue prompts


USR_NAM=$USER
echo "Welcome $USR_NAM, your home is $USR_DIR."
cd $USR_DIR
echo "Running config script..."
if [ "$FAST" != 1 ]
then
    sleep 1
    echo "TEST PRINT"
fi

# Need to enable SSH, user must do this for now
echo "User must enable SSH in GUI..."
sleep 2
#sudo raspi-config

# Update stuff
echo "Update package manager..."
sleep 2
sudo apt-get update -y
sudo apt-get upgrade -y

# Get vim configured
echo "Install and Configure Vim..."
sleep 2
sudo apt-get install vim -y
VIM_RC=$USR_DIR'.vimrc'
echo $VIM_RC
echo 'syntax on               " Enable color coding' >> $VIM_RC
echo 'set tabstop=4           " \t has width 4' >> $VIM_RC
echo 'set shiftwidth=4        " Indents have width of 4' >> $VIM_RC
echo 'set softtabstop=4       " Set number of columns for \t' >> $VIM_RC
echo 'set expandtab           " Expand \t to spaces' >> $VIM_RC

# Get Git configured
echo "Install and configure Git..."
sleep 2
sudo apt-get install git -y

read -p "Please enter you Git username. Simply press Enter to skip this. " GIT_USR
git config --global user.name "$GIT_USR"
echo "Username set: "
git config --global user.name

read -p "Please enter your Git email. Simply press Enter to skip this. " GIT_EMA
git config --global user.email "$GIT_EMA"
echo "Email set: "
git config --global user.email

# Enable key auth, assuming it's in place
echo "Enable SSH Key Auth for Git..."
sleep 2
SSH_CONF=$USR_DIR'.ssh/config'
echo 'host github.com' >> $SSH_CONF
echo '  HostName github.com' >> $SSH_CONF
echo '  IdentityFile ~/.ssh/id_rsa' >> $SSH_CONF
echo '  User git' >> $SSH_CONF

echo "Remember to clone your repos."
sleep 2

# I like tree now that I know about it
echo "Installing Tree..."
sleep 2
sudo apt-get install tree -y

# Need to get MySQL
sudo apt-get install mysql-server python-mysqldb mysql-client -y
# Need to set root password
sleep 2
SQL_PID=`sudo cat /var/run/mysqld/mysqld.pid`
echo "P_ID: $SQL_PID"
sudo kill $SQL_PID
echo "Create temp_conf here:"
pwd
INIT_F=$USR_DIR'temp_conf.sql'
echo "alter user 'root'@'localhost' identified by 'Chance1791';" >> $INIT_F
echo "INIT_F = $INIT_F"
SU_SCR=$USR_DIR'.temp.sh'
echo "mysqld --init-file=$INIT_F &" >> $SU_SCR
sudo rm $INIT_F
sudo chmod u+x $SU_SCR
sudo su -c $SU_SCR
echo 'Works?'
sudo echo $SU_SCR
sudo rm -f $SU_SCR
sudo rm -f $INIT_F
# By this point root will be able to login to mysql

# Need to add a user for the person running the script
SQL_CNF=$USR_DIR'.sql_conf.sql'
read -p "Enter a password for your MySQL localhost account: " SQL_PASS
echo "grant all privileges on test.* to '$SCR_USR'@'localhost' identified by '$SQL_PASS';" >> $SQL_CNF
USR_DB="${SCR_USR}_database"
echo "create database $USR_DB;" >> $SQL_CNF
echo "grant all privileges on $USR_DB.* to '$SCR_USR'@'localhost' identified by '$SQL_PASS';" >> $SQL_CNF
sudo mysql < $SQL_CNF
sudo rm -f $SQL_CNF


# Install nginx webserver
sudo apt-get install nginx -y
sudo systemctl start nginx

#sudo apt-get install php7.0-fpm -y
TMP_EDT='.temp_update'
APT_SRC='/etc/apt/sources.list'
APT_CNF='/etc/apt/preferences'
NGX_CNF='/etc/nginx/sites-enabled/default'
#sudo echo "echo '' >> $APT_SRC " > $TMP_EDT
#sudo echo "echo 'deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi' >> $APT_SRC" >> $TMP_EDT
#sudo echo "echo 'Package: *' >> $APT_CNF" >> $TMP_EDT
#sudo echo "echo 'Pin: release n=jessie' >> $APT_CNF" >> $TMP_EDT
#sudo echo "echo 'Pin-Priority: 600' >> $APT_CNF" >> $TMP_EDT
#sudo echo "sed -i -e 's/index index.html index.htm/index index.php index.html index.htm $NGX_CNF' >> $APT_CNF" >> $TMP_EDT
#sudo chmod u+x $TMP_EDT
#sudo ./$TMP_EDT

#sudo apt-get update
#sudo apt-get install -t  stretch php7.0-fpm -y

#sudo echo "sed -i -e 's/index index.html index.htm/index index.php index.html index.htm/g $NGX_CNF' > $APT_CNF" > $TMP_EDT
#sudo echo "sed -i -e 's/#location ~ \.php$ {/location ~ \.php$ {/g' $NGX_CNF' >> $APT_CNF" >>$TMP_EDT
## FINISH ENABLING PHP 7.0 LATER

# Let's get a firewall setup
sudo apt-get install ufw -y
#sudo ufw allow HTTP
sudo ufw allow ssh





# Any remaining changes need to be made
reboot now
