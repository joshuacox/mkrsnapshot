#!/bin/sh
TMP=$(mktemp -d --suffix=DOCKERTMP)
INVENTORY=$(cat INVENTORY)
grep -v '^#' $INVENTORY > $TMP/inventory
INVENTORY=$TMP/inventory

# make tester.sh file
echo '#!/bin/bash' > $TMP/tester.sh
chmod +x $TMP/tester.sh
#for i in $(grep -v '^#' $INVENTORY);do echo $i|cut --output-delimiter=' ' -f1,2,3,4 -d','|awk '{print "ssh -p " $3 " " $1 "@" $2 " \"uname -a\"" }'>>$TMP/tester.sh ;done
while IFS="," read REMOTE_USER REMOTE_HOST REMOTE_PORT REMOTE_PATH
do
    export REMOTE_USER=$REMOTE_USER
    export REMOTE_HOST=$REMOTE_HOST
    export REMOTE_PORT=$REMOTE_PORT
    export REMOTE_PATH=$REMOTE_PATH
    echo  "ssh $REMOTE_USER@$REMOTE_HOST -p $REMOTE_PORT \"uname -a\"">>$TMP/tester.sh
done < $INVENTORY
echo " "
echo '** These are the hosts I see in the inventory file: **'
cat $TMP/tester.sh
echo '** Running uname -r on all hosts: **'
/bin/bash $TMP/tester.sh
rm -Rf $TMP
