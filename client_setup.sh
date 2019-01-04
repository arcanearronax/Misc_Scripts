#/usr/bin/bash

# Get the local website files set up
mkdir ~/website
cd ~/website

SHIP="client_ship.sh"
PI="10.0.0.5"
WEBDIR="/home/webmaster/web_proj"
BLOG="$WEBDIR/blog"
STATIC="$WEBDIR/static"
scp -r arronax@$PI:$BLOG ./
scp -r arronax@$PI:$STATIC ./

echo "scp -r ./blog arronax@$PI:$WEBDIR" > $SHIP
echo "scp -r ./static arronax@$PI:$WEBDIR" > $SHIP

chmod u+x $SHIP
