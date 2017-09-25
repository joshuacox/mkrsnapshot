#!/bin/bash
TMP=$(mktemp -d --suffix=DOCKERTMP)
INVENTORY=$(cat INVENTORY)
grep -v '^#' $INVENTORY > $TMP/inventory
INVENTORY=$TMP/inventory
# echo $INVENTORY
# for i in $(cat $INVENTORY);do echo $i|cut --output-delimiter=' ' -f1,2,3,4 -d','|awk '{print "REMOTE_USER="$1 " REMOTE_HOST="$2 " REMOTE_PORT="$3 " REMOTE_PATH="$4}' ;done
    #echo  "ssh-keyscan $REMOTE_HOST -p $REMOTE_PORT >>~/.ssh/known_hosts" >> $TMP/keyscan.sh
while IFS="," read REMOTE_USER REMOTE_HOST REMOTE_PORT REMOTE_PATH
do
    export REMOTE_USER=$REMOTE_USER
    export REMOTE_HOST=$REMOTE_HOST
    export REMOTE_PORT=$REMOTE_PORT
    export REMOTE_PATH=$REMOTE_PATH
    echo  "ssh-keyscan -p $REMOTE_PORT $REMOTE_HOST >>$TMP/known_hosts 2>/dev/null " >> $TMP/keyscan.sh
done < $INVENTORY
cat $TMP/keyscan.sh
bash $TMP/keyscan.sh
cd $TMP
cp ~/.ssh/known_hosts $TMP/known_hosts.new
cat $TMP/known_hosts $TMP/known_hosts.new|sort|uniq>$TMP/known_hosts.sorted
diff  $TMP/known_hosts.sorted ~/.ssh/known_hosts
cp -i $TMP/known_hosts.sorted ~/.ssh/known_hosts
cd /tmp
rm -Rf $TMP
