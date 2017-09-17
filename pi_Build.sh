#!/bin/bash

#   Raspberry Pi Build Script
#   arronax - 09/07/2017
#
#   Must run as root
#   To enable SSH at boot: add a file called "ssh" onto boot partition of card

#################################
########### Variables ###########
#################################

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
APT_LOG=".apt.$(date +%H%M%S).log"
APT_GET="0"
REQ_USR="0"

#################################
########### Functions ###########
#################################

# Pass whatever args you want to be recorded and hyphen delimited.
logger() {
    TMP_LOG="$1"
    shift
    while test ${#} -gt 0; do
        TMP_LOG="$TMP_LOG - $1"
        shift
    done
    printf "$TMP_LOG\n" >> "$LOG_FLE"
}

procLog() {
  logger "\tprocLog" "$1"
  printf '\n' >> "$APT_LOG"
  printf "$1\n" >> "$APT_LOG"
}

# Check to see if an arg is being passed again
isCalledAgain() {
    if [ -n "$1" ]; then
        printf "ERROR - is CalledAgin - $1 - $2\n"
        logger "BAILOUT" "isCalledAgain" "$1" "$2"
        exit -1
    fi
}

# Check to see if $2 is a file that exists
doesFileExist() {
    if [ -f "$2" ]; then
        SSH_FLE=1
        logger "doesFileExist" "File Found" "$2" "$SSH_FLE"
    else
        SSH_FLE=0
        logger "doesFileExist" "File Not Found" "$2" "$SSH_FLE"
        printf "WARNING - FILE NOT FOUND - $2\n"
    fi
}

# So we can bail out if the user exists
doesUserExist() {
    TMP_FLE="./.tmp"
    cut -d: -f1 /etc/passwd | grep $NEW_USR > "$TMP_FLE"
    TMP_USR=`grep -w "$NEW_USR" "$TMP_FLE"`
    logger "doesUserExist" "$TMP_USR"
    if [ "$TMP_USR" == "$NEW_USR" ]; then
        USR_EXT="1"
        logger "doesUserExist" "USER DOES EXIST"
        printf "User $NEW_USR already exists.\n"
    elif [ "$TMP_USR" == "" ]; then
        logger "doesUserExist" "USER DOES NOT EXIST"
    else
        printf "Unknown Result. Exiting now.\n"
        logger "doesUserExist" "UNKNOWN RESULT" "BAILOUT"
        exit
    fi
}

# If NEW_USR="", then prompt user for the user's name
getUserName() {
    if [ "$NEW_USR" == "" ]; then
        read -p "Please enter the name of the relevant user: " NEW_USR
        logger "getUserName" "$NEW_USR"

        doesUserExist
        if [ "$USR_EXT" != "1" ]; then
            logger "getUserName" "User Exists"
        else
            logger "getUserName" "User Does Not Exist"
        fi
    fi
}

#################################
########### Main Func ###########
#################################

logger "pi_Build.sh" "BEGIN"

# In case no args are passed
if [ ${#} -eq 0 ]; then
    printf "No args yo.\n"
    printf "EXIT ON" "NO ARGS"
    exit -1
fi

# Let's process the command line args
logger "PROCESS ARGS"
logger "Args Received" "$@"
while test ${#} -gt 0; do
    case "$1" in
        -[Uu]|--user)
            # Enter
            printf "Add User - $2\n"
            logger "\tUSER" "ARGS" "BEGIN" "$2"
            # Validate
            TMP="$2"
            isCalledAgain "$NEW_USR" "$TMP"
            NEW_USR=$2
            # Process aux args
            if [ "$1" = "-U" ]; then
                USR_PSD=1
                printf "Add User - with sudo\n"
            fi
            REQ_USR="1"
            # Finalize
            shift
            ;;
        -g|--git)
            # Document
            printf "Install Git - $2 $3 $4\n"
            logger "\tGIT" "ARGS" "$GIT_USR" "$2" "$3" "$4"
            # Validate
            TMP="$2"
            isCalledAgain "$GIT_USR" "$TMP"
            # Process aux args
            GIT_USR="$2"
            GIT_EML="$3"
            GIT_KEY="$4"
            APT_GET="1"
            REQ_USR="1"
            # Finalize
            shift
            shift
            shift
            shift
            ;;
        -v|--vim)
            # Document
            printf "Install Vim\n"
            logger "\tVIM" "ARGS"
            # Validate
            isCalledAgain "$VIM_TOO"
            # Process aux args
            VIM_TOO="1"
            APT_GET="1"
            REQ_USR="1"
            # Finalize
            ;;
        -s|--ssh)
            # Document
            printf "Configure SSH\n"
            logger "SSH" "ARGS" "$2"
            # Validate
            TMP="$2"
            isCalledAgain "$SSH_PTH" "$TMP"
            doesFileExist "$2"
            # Process aux args
            SSH_PTH="$2"
            REQ_USR="1"
            # Finalize
            shift
            ;;
        -t|--tree)
            # Document
            printf "Install Tree\n"
            logger "\tTREE" "ARGS"
            # Validate
            isCalledAgain "$TRE_TOO"
            # Process aux args
            TRE_TOO="1"
            APT_GET="1"
            # Finalize
            logger "\tTREE" "ARGS" "$TRE_TOO"
            ;;
        -m|--mysql)
            # Document
            printf "Install MySQL\n"
            logger "\tMYSQL" "ARGS"
            # Validate
            isCalledAgain "$MSL_TOO"
            # Process aux args
            MSL_TOO="1"
            APT_GET="1"
            REQ_USR="1"
            # Finalize
            ;;
        -n|--nginx)
            # Document
            printf "Install Nginx\n"
            logger "\tNGINX" "ARGS"
            # Validate
            isCalledAgain "$NGX_TOO"
            # Process aux args
            NGX_TOO="1"
            APT_GET="1"
            # Finalize
            ;;
        -f|--ufw)
            # Document
            printf "Install UFW\n"
            logger "\tUFW" "ARGS" "$2"
            # Validate
            isCalledAgain "$UFW_TOO"
            # Process aux args
            UFW_TOO="1"
            UFW_SSH="$2"
            APT_GET="1"
            # Finalize
            shift
            ;;
        -l|--log)
            isCalledAgain "$LOG_FLE"
            LOG_FLE="$2"
            printf "LOG FILE\n"
            ;;
        *)
            printf "Dude, what?\n"
            exit 1
            ;;
    esac
    shift
done

printf "$LOG_FLE\n" > "$APT_LOG"

if [ "$APT_GET" == "1" ]; then
    logger "APT-GET UPDATE" "BEGIN"

    APT_UPD="apt-get -y update"
    procLog "$APT_UPD"
    `$APT_UPD &>> "$APT_LOG"`

    APT_UPG="apt-get -y upgrade"
    procLog "$APT_UPG"
    `$APT_UPG &>> "$APT_LOG"`
    logger "APT_GET UPDATE" "COMPLETE"
fi

#exit -1

# Add User
if [  "$NEW_USR" != "" ]; then
    # Need to check to see if the passed user exists
    USR_EXT=""
    doesUserExist
    if [ "$USR_EXT" == "" ]; then
        logger "ADDUSER" "BEGIN" "$NEW_USR"
        adduser "$NEW_USR"
        if [ "$USR_PSD" ==  "1" ]; then
            adduser "$NEW_USR" sudo
            logger "\tADDUSER" "GOT SUDO"
        fi
        logger "\tADDUSER" "$NEW_USR" "$USR_PSD"
    fi
    logger "ADDUSER" "COMPLETE"

else
    if [ "$REQ_USR" == "1" ]; then
        logger "ADD USER" "REQ USR"
        USR_EXT=""
        while [ "$USR_EXT" != "1" ]
        do
            getUserName
        done
    fi
fi



# Configure SSH
if [ "$SSH_PTH" != "" ]; then
    logger "CONFIGURE SSH" "BEGIN"
    getUserName
    SSH_DIR="/home/$NEW_USR/.ssh/"
    SSH_PUB="id_rsa.pub"
    install -d -m 700 "$SSH_DIR"
    mv "$SSH_PTH" "$SSH_DIR$SSH_PUB"
    chown "$NEW_USR" "$SSH_DIR"
    echo "SSH should have been enabled at boot"
    cat "$SSH_DIR$SSH_PUB" | ssh "$NEW_USR"@192.168.1.76 cat >> "$SSH_DIR""authorized_keys"
    logger "SSH CONFIG" `cat "$SSH_DIR""authorized_keys"`
    logger "CONFIGURE SSH" "COMPLETE"
fi

# Configure Vim
# We don\'t deserve Vim being set up properly
# Until we can set up SSH properly.
if [ "$VIM_TOO" == "1" ]; then
    logger "CONFIGURE Vim" "BEGIN"
    getUserName
    apt-get install vim -y &>> "$APT_LOG"
    VIM_CNF="/home/$NEW_USR/.vimrc"
    echo 'syntax on               " Enable color coding' >> "$VIM_CNF"
    echo 'set tabstop=4           " \t has width 4' >> "$VIM_CNF"
    echo 'set shiftwidth=4        " Indents have width of 4' >> "$VIM_CNF"
    echo 'set softtabstop=4       " Set number of columns for \t' >> "$VIM_CNF"
    echo 'set expandtab           " Expand \t to spaces' >> "$VIM_CNF"
    logger "CONFIGURE Vim" "COMPLETED"
fi


if [ "$GIT_USR" != "" ]; then
    logger "INSTALL GIT" "Begin"
    GIT_DIR="/home/$NEW_USR/.gitconfig"
    logger "INSTALL GIT" "$GIT_USR" "$GIT_KEY" "$GIT_DIR" "$GIT_EML"
    getUserName
    apt-get install git -y &>> "$APT_LOG"

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
    logger "INSTALL GIT" "COMPLETE"
fi

# Install Tree
if [ "$TRE_TOO" == "1" ]; then
    logger "INSTALL TREE" "BEGIN"
    apt-get install tree -y &>> "$APT_LOG"
    logger "INSTALL TREE" "COMPLETE"
fi

# Install UFW
if [ "$UFW_TOO" == "1" ]; then
    logger "INSTALL UFW" "BEGIN"
    apt-get install ufw -y &>> "$APT_LOG"

    if [ "$UFW_SSH" == "SSH" ]; then
        ufw allow ssh
    fi

    ufw enable
    logger "INSTALL UFW" "COMPLETE"
fi

# Install MySQL
# This is gonna be fun...
if [ "$MSL_TOO" == "1" ]; then
    logger "INSTALL MYSQL" "BEGIN"
    apt-get install mysql-server python-mysqldb mysql-client -y &>> "$APT_LOG"

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
    logger "INSTALL MYSQL" "COMPLETE"
fi

# Install NGINX
if [ "$NGX_TOO" == "1" ]; then
    logger "INSTALL NGINX" "BEGIN"
    apt-get install nginx -y &>> "$APT_LOG"

    # Need php and mysql integration
    apt-get install php7.0-fpm php7.0-cgi php7.0-mysql -y &>> "$APT_LOG"

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
    sed -i '70s/#}/}/g' "$NGX_PHP" # Shut up...

    # This will need some additional logic...
    ufw allow http
    ufw allow https
    nginx -t
    systemctl reload nginx
    logger "INSTALL NGINX" "COMPLETE"
fi






logger "pi_Build.sh" "COMPLETE"
