#!/bin/bash

function logger {
    echo -e "${*}" >> "$LOGFILE"
}

function enterFuncLog {
    logger "Enter: ${FUNCNAME[1]}"
}

function exitFuncLog {
    logger "Exit: ${FUNCNAME[1]}" 
}

function fileNotFound {
    logger "$1 Not Found"
}

function readInput {
    enterFuncLog

    # Check to make sure we have some args included
    if [ ${#} -eq 0 ]; then

        echo "No args provided"
        exit 1

    fi

    # Now let's loop over the args and record the inputs
    while test ${#} -gt 0; do
        case "$1" in
            -c|--config)
                logger "\tCFG FILE: $2"
                [ -e "$2" ] && CFGFILE="$2" || fileNotFound "Config"
                echo "CONFIG = $CFGFILE"
                shift
                break
                ;;
            *)
                logger "\tUnknown: ${*}"
                ;;
        esac
        shift
    done

    # Now read in the config file args
    logger "\tReading CFGFILE args"
    while IFS= read -r LINE; do
        OPT=`echo "$LINE" | awk -F '=' '{print $1}'`
        VAL=`echo "$LINE" | awk -F '=' '{print $2}'`
        case "$OPT" in 
            CFGUSER)
                CFGUSER="$VAL"
                echo "CFGUSER = $CFGUSER"
                ;;
            PROFILE)
                PROFILE="$VAL"
                echo "PROFILE = $PROFILE"
                ;;
            KEY)
                [ -e "$VAL" ] && KEY="$VAL" || fileNotFound "\tKey"
                echo "KEY = $KEY"
                ;;
            LOCAL)
                [ -e "$VAL" ] && LOCAL="$VAL" || fileNotFound "\tLocal File"
                ;;
            REMOTE)
                REMOTE="$VAL"
                ;;
            *)
                logger "\tUnknown: OPT=$OPT - VAL=$VAL"
                ;;
        esac

    done < "$CFGFILE"

    exitFuncLog
}

#LOGFILE="$0"."$$"
LOGFILE="templog"
readInput ${*}
