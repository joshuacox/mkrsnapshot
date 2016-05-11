#!/bin/bash
for i in $(cat INVENTORY);do  \
echo $i|cut -f1 -d','> REMOTE_USER ; \
echo $i|cut -f2 -d','> REMOTE_HOST ; \
echo $i|cut -f3 -d','> REMOTE_PORT ; \
echo $i|cut -f4 -d','> REMOTE_PATH ; \
done
