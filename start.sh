#!/bin/sh
echo -e  'y\n'|ssh-keygen -q -t ecdsa -N "" -f ~/.ssh/id_ecdsa > /dev/null 2>&1
rm  -f /root/.ssh/authorized_keys

cp -a /root/keys/id* /root/.ssh/
cp -a /root/keys/known_hosts /root/.ssh/

chmod 600 /root/.ssh/id*
chmod 600 /root/.ssh/known_hosts

chown root. /root/.ssh/id*
chown root. /root/.ssh/known_hosts

#autossh -M $MONITOR_PORT  -g -L $LOCAL_PORT:0.0.0.0:$FORWARDED_PORT -f -p$REMOTE_PORT -N $REMOTE_USER@$REMOTE_HOST
mkdir -p /backups/$REMOTE_HOST/$REMOTE_USER/$REMOTE_PATH 
rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH /backups/$REMOTE_HOST/$REMOTE_USER/$REMOTE_PATH 

