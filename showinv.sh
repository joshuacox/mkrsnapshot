#!/bin/bash
TMP=$(mktemp -d --suffix=DOCKERTMP)
INVENTORY=$(cat INVENTORY)
grep -v '^#' $INVENTORY > $TMP/inventory
INVENTORY=$TMP/inventory
echo $INVENTORY
# for i in $(cat $INVENTORY);do echo $i|cut --output-delimiter=' ' -f1,2,3,4 -d','|awk '{print "REMOTE_USER="$1 " REMOTE_HOST="$2 " REMOTE_PORT="$3 " REMOTE_PATH="$4}' ;done
while IFS="," read REMOTE_USER REMOTE_HOST REMOTE_PORT REMOTE_PATH
do
    echo  "$REMOTE_USER $REMOTE_HOST $REMOTE_PORT $REMOTE_PATH"
done < $INVENTORY
