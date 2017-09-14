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
            logger "USER" "BEGIN" "$NEW_USR" "$2"
            if [ $1 = "-U" ]; then
                USR_PSD=1
                echo "SUDO"
            fi
            isCalledAgain "$NEW_USR" "$TMP"
            NEW_USR=$2
            logger "USER" "COMPLETE" "$USR_PSD"
            shift
            ;;
        -g|--git)
            TMP=$2
            logger "GIT" "BEGIN" "$GIT_USR" "$2" "$3"
            isCalledAgain "$GIT_USR" "$TMP"
            GIT_USR=$2
            GIT_EML=$3
            logger "GIT" "COMPLETE"
            shift
            shift
            ;;
        -v|--vim)
            logger "VIM" "BEGIN"
            isCalledAgain "$VIM_TOO"
            VIM_TOO="1"
            echo "Vim too"
            logger "VIM" "COMPLETE"
            ;;
        -s|--ssh)
            TMP=$2
            logger "SSH" "BEGIN" "$SSH_PTH" "$2"
            isCalledAgain "$SSH_PTH" "$TMP"
            doesFileExist $2
            SSH_PTH=$2
            echo $SSH_PTH
            logger "SSH" "COMPLETE"
            shift
            ;;
        -t|--tree)
            logger "TREE" "BEGIN"
            isCalledAgain "$TRE_TOO"
            TRE_TOO="1"
            echo "Tree too"
            logger "TREE" "COMPLETE"
            ;;
        -m|--mysql)
            logger "MYSQL" "BEGIN"
            isCalledAgain "$MSL_TOO"
            MSL_TOO="1"
            echo "MySQL too"
            logger "MYSQL" "COMPLETE"
            ;;
        -n|--nginx)
            isCalledAgain "$NGX_TOO"
            NGX_TOO="1"
            echo "Nginx too"
            ;;
        -f|--ufw)
            isCalledAgain "$UFW_TOO"
            UFW_TOO="1"
            echo "UFW too"
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
#logger "ADDUSER" "BEGIN"
#echo "test" "$NEW_USR"
#if [  "$NEW_USR" != "" ]; then
#    echo "PLEASE MORE HELP"
#    adduser $NEW_USR
#    if [ "$USR_PSD" ==  "1" ]; then
#        adduser $NEW_USR sudo
#        logger "ADDUSER" "GOT SUDO"
#    fi
#    logger "ADDUSER" "$NEW_USR" "$USR_PSD"
#fi
#logger "ADDUSER" "COMPLETE"

# Configure SSH
#logger "CONFIGURE SSH" "BEGIN"
#if [ "$SSH_PTH" != "" ]; then
#    getUserName
#    SSH_DIR="/home/$NEW_USR/.ssh/"
#    SSH_PUB="id_rsa.pub" 
#    echo "SSH should have been enabled at boot"
#    install -d -m 700 $SSH_DIR
#    sudo chown $NEW_USR $SSH_DIR
#    mv $SSH_PTH $SSH_DIR$SSH_PUB
#    cat $SSH_DIR$SSH_PUB | ssh $NEW_USR@192.168.1.76 cat >> $SSH_DIR"authorized_keys"
#    logger "SSH CONFIG" `cat $SSH_DIR"authorized_keys"`

#fi
#logger "CONFIGURE SSH" "COMPLETE"

# Configure Vim
# We don\'t deserve Vim being set up properly
# Until we can set up SSH properly.
#logger "CONFIGURE Vim" "BEGIN"
#if [ "$VIM_TOO" == "1" ]; then
#    getUserName
#    apt-get install vim -y
#    VIM_CNF="/home/$NEW_USR/.vimrc"
#    echo 'syntax on               " Enable color coding' >> $VIM_CNF
#    echo 'set tabstop=4           " \t has width 4' >> $VIM_CNF
#    echo 'set shiftwidth=4        " Indents have width of 4' >> $VIM_CNF
#    echo 'set softtabstop=4       " Set number of columns for \t' >> $VIM_CNF
#    echo 'set expandtab           " Expand \t to spaces' >> $VIM_CNF
#fi
#logger "CONFIGURE Vim" "COMPLETED"

#
#
# Main functions above here have been verified
#
#

if [ "$GIT_USR" != "" ]; then
    GIT_DIR="/home/$NEW_USR/.gitconfig"
    apt-get install git -y
    
    echo "[user]" > "$GIT_DIR"
    echo "\tname = $GIT_USR" >> "$GIT_DIR"
    echo "\temail = $GIT_EML" >> "$GIT_DIR"

    if [ "$VIM_TOO" == "1" ]; then
        echo "[core]" >> "$GIT_DIR"
        echo "\teditor = vim" >> "$GIT_DIR"
    fi

fi










logger "pi_Build.sh" "COMPLETE" 
