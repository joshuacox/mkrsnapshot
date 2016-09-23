#!/bin/sh
echo -e  'y\n'|ssh-keygen -q -t ecdsa -N "" -f ~/.ssh/id_ecdsa > /dev/null 2>&1
rm  -f /root/.ssh/authorized_keys

cp -a /root/keys/id* /root/.ssh/
cp -a /root/keys/known_hosts /root/.ssh/

chmod 600 /root/.ssh/id*
chmod 600 /root/.ssh/known_hosts

chown root. /root/.ssh/id*
chown root. /root/.ssh/known_hosts

INVENTORY=/root/inventory
# make sync.sh file
rm -f /tmp/sync.sh
echo '#!/bin/bash' >> /tmp/sync.sh
chmod +x /tmp/sync.sh
# mkdir 
for i in $(grep -v '^#' $INVENTORY);do echo $i|cut --output-delimiter=' ' -f1,2,3,4 -d','|awk '{print "REMOTE_USER="$1 " REMOTE_HOST="$2 " REMOTE_PORT="$3 " REMOTE_PATH="$4 " mkdir -p /backups/$REMOTE_HOST/$REMOTE_USER"}' >>/tmp/sync.sh ;done
# echo
echo "rsync -av $INVENTORY /backups/"
for i in $(grep -v '^#' $INVENTORY);do echo $i|cut --output-delimiter=' ' -f1,2,3,4 -d','|awk '{print "rsync -ave \"ssh -p " $3 "\" --relative " $1 "@" $2 ":" $4 " /backups/" $2 "/" }'>>/tmp/sync.sh ;done
cat /tmp/sync.sh
/bin/bash /tmp/sync.sh
rsnapshot sync
rsnapshot hourly
rsnapshot daily
rsnapshot weekly

