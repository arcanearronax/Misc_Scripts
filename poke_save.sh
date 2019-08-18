#!/bin/bash

#################################################################
# poke_save.sh                                                  #
# arcanearronax                                                 #
#                                                               #
# Requires mkdir, cp, scp, tar                                  #
# 1. Place in directory with game saves.                        #
# 2. Ensure the remote directory is accesible.                  #
# 3. Cron the script to run every 5 minutes.                    #
#################################################################

# Set logging info
LOGFILE="poke.log"
function log() {
  CURDATE=`date +"%m%d%y%H%M%S"`
  if [[ -n "$@" ]]; then
    echo "$CURDATE-$@" >> "$CURDIR/$LOGFILE"
  fi
}

# Gather our working info
CURDIR=`pwd`
WORKDIR="$CURDIR/.working"
FILEREG="*.sav"
mkdir -p "$WORKDIR"

# Setup save file stuff
SAVEDATE=`date +"%m%d%Y%H%M%S"`
SAVEDIR="$WORKDIR/saves_$SAVEDATE"
TARFILE="$SAVEDIR.tar"
REMOTEDIR="/home/arronax/Documents/poke_saves"
REMOTEUSER="arronax"
REMOTEDOMAIN="vendigroth.local"


# Gather the saves
log `mkdir -p $SAVEDIR 2>&1`
for filename in `ls $FILEREG`; do
    log "got $filename..."
    cp $filename "$SAVEDIR/"
done

# Create our tar ball
log "Making tarball:   $TARFILE"
log `tar -cvf "$TARFILE" "$SAVEDIR" 1>/dev/null 2>&1`
log `rm -r $SAVEDIR 2>&1`

# Send our tar ball off
log "Sending file: $TARFILE"
log `scp $TARFILE "$REMOTEUSER"@"$REMOTEDOMAIN":"$REMOTEDIR" `
log "completed"
log `rm "$TARFILE" 2>&1`
