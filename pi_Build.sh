#!/bin/bash

#   Raspberry Pi Build Script
#   arronax - 09/07/2017
#   
#   Must run as root

#   Uncomment most everything before running
#   See usage below

#   To enable SSH at boot: add a file called "ssh" onto boot partition of card

# Functions

logger() {
    TMP_LOG="$1"
    shift
    while test ${#} -gt 0; do
        TMP_LOG=$TMP_LOG" - "$1
        shift
    done
    echo $TMP_LOG >> $LOG_FLE
}

isCalledAgain() {
    if [ -n "$1" ]; then
        #echo "Error: Attempted Redeclaration. OLD: $1. NEW: $2."
        echo "isCalled:$"="1 " $1
        echo "isCalled:$"="2 " $2
        echo "BAILOUT"
        logger "BAILOUT" "isCalledAgain" "$1" "$2"
        exit -1
    fi
}

doesFileExist() {
    if [ -f $2 ]; then
        SSH_FLE=1
        logger "doesFileExist" "File Found" $2 $SSH_FLE
    else
        SSH_FLE=0
        logger "doesFileExist" "File Not Found" $2 $SSH_FLE
        echo "WARNING - FILE NOT FOUND - $2"
    fi
    
    
}

getUserName() {
    if [ "$NEW_USR" == "" ]; then
        read -p "Please enter the name of the relevant user: " NEW_USR
        logger "getUserName" "$NEW_USR"
    fi
}

# Need to declare some variables for our work
NEW_USR=""
USR_PSD=""
GIT_USR=""
GIT_EML=""
SSH_PTH=""
SSH_FLE=""
VIM_TOO=""
TRE_TOO=""
MSL_TOO=""
NGX_TOO=""
UFW_TOO=""
LOG_FLE=".pi_Build."$(date +%H%M%S)".log"
CUR_PRC=""

logger "pi_Build.sh" "BEGIN"

ARG_CNT=${#}
# Let's process the command line args
logger "***PROCESS ARGS***"
logger "**Cycle Args" $@
while test ${#} -gt 0; do
    case $1 in
        -[Uu]|--user)
            TMP=$2
            echo "Add User - $2"
            logger "USER" "ARGS" "$NEW_USR" "$2"
            if [ $1 = "-U" ]; then
                USR_PSD=1
                echo "Add User - with sudo"
            fi
            isCalledAgain "$NEW_USR" "$TMP"
            NEW_USR=$2
            logger "USER" "ARGS" "$USR_PSD"
            shift
            ;;
        -g|--git)
            TMP=$2
            echo "Install Git - $2 $3 $4"
            logger "GIT" "ARGS" "$GIT_USR" "$2" "$3" "$4"
            isCalledAgain "$GIT_USR" "$TMP"
            GIT_USR=$2
            GIT_EML=$3
            GIT_KEY=$4
            logger "GIT" "ARGS"
            shift
            shift
            shift
            shift
            ;;
        -v|--vim)
            echo "Install Vim"
            logger "VIM" "ARGS"
            isCalledAgain "$VIM_TOO"
            VIM_TOO="1"
            logger "VIM" "COMPLETE"
            ;;
        -s|--ssh)
            TMP=$2
            echo "Configure SSH"
            logger "SSH" "ARGS" "$SSH_PTH" "$2"
            isCalledAgain "$SSH_PTH" "$TMP"
            doesFileExist $2
            SSH_PTH=$2
            echo $SSH_PTH
            logger "SSH" "ARGS" 
            shift
            ;;
        -t|--tree)
            echo "Install Tree"
            logger "TREE" "ARGS"
            isCalledAgain "$TRE_TOO"
            TRE_TOO="1"
            logger "TREE" "ARGS" "$TRE_TOO"
            ;;
        -m|--mysql)
            echo "Install MySQL"
            logger "MYSQL" "ARGS"
            isCalledAgain "$MSL_TOO"
            MSL_TOO="1"
            logger "MYSQL" "ARGS" "$MSL_TOO"
            ;;
        -n|--nginx)
            echo "Install Nginx"
            logger "NGINX" "ARGS"
            isCalledAgain "$NGX_TOO"
            NGX_TOO="1"
            logger "NGINX" "ARGS" "$NGX_TOO"
            ;;
        -f|--ufw)
            echo "Install UFW"
            logger "UFW" "ARGS" "$2"
            isCalledAgain "$UFW_TOO"
            UFW_TOO="1"
            UFW_SSH="$2"
            logger "UFW" "ARGS" "$UFW_TOO"
            echo "UFW too"
            shift
            ;;
        -l|--log)
            isCalledAgain "$LOG_FLE"
            LOG_FLE="$2"
            echo "LOG FILE"
            ;;
        *)
            echo "Dude, what?"
            exit 1
            ;;
    esac
    shift
done

# In case we didn't do anything yet
if [ $ARG_CNT -eq 0 ]; then
    echo "No args yo."
    exit -1
fi

if [ "$VIM_TOO" != "" ] || [ "$MSL_TOO" != "" ] || [ "$TRE_TOO" != "" ] || [ "$GIT_USR" != "" ] || [ "$NGX_TOO" != "" ] || [ "$UFW_TOO" != "" ]; then
    logger "APT-GET UPDATE"
    apt-get -y update
    apt-get -y upgrade
fi

# Add User
logger "ADDUSER" "BEGIN"
echo "test" "$NEW_USR"
if [  "$NEW_USR" != "" ]; then
    echo "PLEASE MORE HELP"
    adduser $NEW_USR
    if [ "$USR_PSD" ==  "1" ]; then
        adduser $NEW_USR sudo
        logger "ADDUSER" "GOT SUDO"
    fi
    logger "ADDUSER" "$NEW_USR" "$USR_PSD"
fi
logger "ADDUSER" "COMPLETE"

# Configure SSH
logger "CONFIGURE SSH" "BEGIN"
if [ "$SSH_PTH" != "" ]; then
    getUserName
    SSH_DIR="/home/$NEW_USR/.ssh/"
    SSH_PUB="id_rsa.pub" 
    install -d -m 700 "$SSH_DIR"
    mv "$SSH_PTH" "$SSH_DIR$SSH_PUB"
    chown "$NEW_USR" "$SSH_DIR"
    echo "SSH should have been enabled at boot"
    cat $SSH_DIR$SSH_PUB | ssh $NEW_USR@192.168.1.76 cat >> $SSH_DIR"authorized_keys"
    logger "SSH CONFIG" `cat $SSH_DIR"authorized_keys"`
fi
logger "CONFIGURE SSH" "COMPLETE"

# Configure Vim
# We don\'t deserve Vim being set up properly
# Until we can set up SSH properly.
logger "CONFIGURE Vim" "BEGIN"
if [ "$VIM_TOO" == "1" ]; then
    getUserName
    apt-get install vim -y
    VIM_CNF="/home/$NEW_USR/.vimrc"
    echo 'syntax on               " Enable color coding' >> $VIM_CNF
    echo 'set tabstop=4           " \t has width 4' >> $VIM_CNF
    echo 'set shiftwidth=4        " Indents have width of 4' >> $VIM_CNF
    echo 'set softtabstop=4       " Set number of columns for \t' >> $VIM_CNF
    echo 'set expandtab           " Expand \t to spaces' >> $VIM_CNF
fi
logger "CONFIGURE Vim" "COMPLETED"


logger "INSTALL GIT" "Begin"
if [ "$GIT_USR" != "" ]; then
    GIT_DIR="/home/$NEW_USR/.gitconfig"
    logger "INSTALL GIT" "$GIT_USR" "$GIT_KEY" "$GIT_DIR" "$GIT_EML"
    getUserName
    apt-get install git -y
    
    echo "[user]" > "$GIT_DIR"
    echo "  name = $GIT_USR" >> "$GIT_DIR"
    echo "  email = $GIT_EML" >> "$GIT_DIR"

    if [ "$VIM_TOO" == "1" ]; then 
        echo "[core]" >> "$GIT_DIR"
        echo "  editor = vim" >> "$GIT_DIR"
        logger "INSTALL GIT" "Vim Too"
    fi

    # add a key
    KEY_DIR="/home/$NEW_USR/.ssh/id_rsa"
    mv "$GIT_KEY" "$KEY_DIR"
    ssh-add "$KEY_DIR"
    chmod 644 "$KEY_DIR"

    SSH_CNF="/home/$NEW_USR/.ssh/config"
    echo "host github.com" >> "$SSH_CNF"
    echo "  HostName github.com" >> "$SSH_CNF"
    echo "  IdentityFile ~/.ssh/id_rsa" >> "$SSH_CNF"
    echo "  User git" >> "$SSH_CNF"
    chmod 600 "$SSH_CNF"

    # Let's make sure it got set up
    TMP=""
    TMP=`cat "/home/$NEW_USR/.ssh/known_hosts" | grep github.com`
    logger "INSTALL GIT" "KNOWN HOSTS"
    if [ "$TMP" == "" ]; then
        logger "INSTALL GIT" "TMP NULL"
    else
        logger "INSTALL GIT" "TMP" " "
        logger "$TMP"
    fi
fi
logger "INSTALL GIT" "COMPLETE"

# Install Tree
logger "INSTALL TREE" "BEGIN"
if [ "$TRE_TOO" == "1" ]; then
    apt-get install tree -y
fi

# Install UFW
logger "INSTALL UFW" "BEGIN"
if [ "$UFW_TOO" == "SSH" ]; then
    apt-get install ufw -y

    if [ "$UFW_SSH" == "SSH" ]; then
        ufw allow ssh
    fi

    ufw enable
fi
logger "INSTALL UFW" "COMPLETE"

# Install MySQL
# This is gonna be fun...
logger "INSTALL MYSQL" "BEGIN"
if [ "$MSL_TOO" == "1" ]; then
    apt-get install mysql-server python-mysqldb mysql-client -y

    # Now let's kill the running process so we can auto-config
    sleep 2
    MSL_PID=""
    MSL_PID=`ps -ef | grep mysqld | grep ? | awk '{ print $2}'`

    if [ "$MSL_PID" != "" ]; then
        kill "$MSL_PID"
        logger "INSTALL MYSQL" "KILLED" "$MSL_PID"
        MSL_PID=""
    else
        echo "PROCESS ID NOT FOUND"
        logger "INSTALL MYSQL" "PID NOT FOUND"
    fi

    # Time for config stuff
    getUserName
    MSL_DIR="/home/$NEW_USR"
    MSL_CNF="$MSL_DIR/temp_conf.sql"
    ROT_PSD=""
    read -p "Enter root password for MYSQL Database: " ROT_PSD
    echo "alter user 'root'@'localhost' identified by '$ROT_PSD';" >> "$MSL_CNF"
    logger "INSTALL MYSQL" "ROOT CONF" "COMPLETE"
    `mysqld --init-file="$MSL_CNF" &`
    # Root will be able to login to MySQL by this point

    MSL_PSD=""
    USR_CNF="/home/$NEW_USR/temp_usr.sql"
    read -p "Please enter $NEW_USR's password for MySQL: " MSL_PSD
    echo "create database $NEW_USR;" > "$USR_CNF"
    echo "grant all privileges on $NEW_USR.* to '$NEW_USR'@'localhost' identified by '$MSL_PSD';" >> "$USR_CNF"
    echo "flush privileges;" >> "$USR_CNF"
    logger "INSTALL MYSQL" "USER CONF" "COMPLETE"
    mysql < "$USR_CNF"

    rm -rf "$MSL_CNF"
    rm -rf "$USR_CNF"    

fi
logger "INSTALL MYSQL" "COMPLETE"

# Install NGINX
logger "INSTALL NGINX" "BEGIN"
if [ "$NGX_TOO" == "1" ]; then
    apt-get install nginx -y

    # Need php and mysql integration
    apt-get install php7.0-fpm php7.0-cgi php7.0-mysql -y
    
    # Configure php
    PHP_CNF="/etc/php/7.0/cgi/php.ini"
    sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' "$PHP_CNF"
    systemctl restart php7.0-fpm

    # Enable nginx to use php
    NGX_PHP="/etc/nginx/sites-available/default"
    # index index.html index.htm index.nginx-debian.html
    sed -i 's/index index.html index.htm index.nginx-debian.html;/index index.php index.html index.htm index.nginx-debian.html;/g' "$NGX_PHP"
    sed -i 's/#location \~ \\.php\$ {/location \~ \\.php\$ {/g' "$NGX_PHP"
    sed -i 's/#\tinclude snippets\/fastcgi-php.conf;/\tinclude snippets\/fastcgi-php.conf;/g' "$NGX_PHP"
    sed -i 's/#\tfastcgi_pass unix:\/var\/run\/php\/php7.0-fpm.sock;/\tfastcgi_pass unix:\/var\/run\/php\/php7.0-fpm.sock;/g' "$NGX_PHP"
    sed -i '63s/#}/}/g' "$NGX_PHP" # Yeah, not too proud of this.
    sed -i 's/#location \~ \/\\.ht {/location \~ \/\\.ht {/g' "$NGX_PHP"
    sed -i 's/#\tdeny all;/\tdeny all;/g' "$NGX_PHP"
    sed -i '70s/#}/}/g' "$NGX_PHP"
    
    # This will need some additional logic...
    ufw allow http
    ufw allow https
    nginx -t
    systemctl reload nginx

fi
logger "INSTALL NGINX" "COMPLETE"






logger "pi_Build.sh" "COMPLETE" 
