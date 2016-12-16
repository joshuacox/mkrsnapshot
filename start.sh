#!/bin/sh
echo -e  'y\n'|ssh-keygen -q -t ecdsa -N "" -f ~/.ssh/id_ecdsa > /dev/null 2>&1
rm  -f /root/.ssh/authorized_keys

cp -a /root/keys/id* /root/.ssh/
cp -a /root/keys/known_hosts /root/.ssh/

chmod 600 /root/.ssh/id*
chmod 600 /root/.ssh/known_hosts

chown root. /root/.ssh/id*
chown root. /root/.ssh/known_hosts

rsync -av /root/inventory /backups/
TMP=$(mktemp -d --suffix=SNAPTMP)
grep -v '^#' /root/inventory > $TMP/inventory
INVENTORY=$TMP/inventory
# make sync.sh file
rm -f $TMP/sync.sh
#echo '#!/bin/bash' >> $TMP/sync.sh
chmod +x $TMP/sync.sh
# mkdir 
#for i in $(cat $INVENTORY);do echo $i|cut --output-delimiter=' ' -f1,2,3,4 -d','|awk '{print "REMOTE_USER="$1 " REMOTE_HOST="$2 " REMOTE_PORT="$3 " REMOTE_PATH="$4 " mkdir -p /backups/$REMOTE_HOST/$REMOTE_USER"}' >>$TMP/sync.sh ;done
# echo
#for i in $(cat $INVENTORY);do echo $i|cut --output-delimiter=' ' -f1,2,3,4 -d','|awk '{print "rsync -ave \"ssh -p " $3 "\" --relative " $1 "@" $2 ":" $4 " /backups/" $2 "/" }'>>$TMP/sync.sh ;done
while IFS="," read REMOTE_USER REMOTE_HOST REMOTE_PORT REMOTE_PATH
do
    echo "mkdir -p /backups/$REMOTE_HOST/$REMOTE_USER" >>$TMP/dirmk.sh
    echo "rsync -ave \"ssh -p $REMOTE_PORT \" --relative  $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH  /backups/$REMOTE_HOST/" >>$TMP/sync.sh
done < $INVENTORY
cat $TMP/dirmk.sh
bash $TMP/dirmk.sh
rm $TMP/dirmk.sh
shuf --random-source=/dev/urandom $TMP/sync.sh --output=$TMP/rand.sh
shuf --random-source=/dev/random $TMP/rand.sh --output=$TMP/shuff.sh
rm  $TMP/sync.sh
rm  $TMP/rand.sh
cat $TMP/shuff.sh
/usr/bin/time parallel --jobs $PARALLEL_JOBS  -- < $TMP/shuff.sh
rm $TMP/shuff.sh
rsnapshot sync
#rsnapshot hourly
#rsnapshot daily
#rsnapshot weekly
rsnapshot $RSNAPSHOT_PERIOD
