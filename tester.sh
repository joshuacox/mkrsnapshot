#!/bin/sh
export TMP=$(mktemp -d --suffix=TMP)
export INVENTORY=$(cat INVENTORY)

# make tester.sh file
echo '#!/bin/bash' >> $TMP/tester.sh
chmod +x $TMP/tester.sh
for i in $(grep -v '^#' $INVENTORY);do echo $i|cut --output-delimiter=' ' -f1,2,3,4 -d','|awk '{print "ssh -p " $3 " " $1 "@" $2 " \"uname -a\"" }'>>$TMP/tester.sh ;done
echo " "
echo "starting GNU parallel to run the following"
echo " "
cat $TMP/tester.sh
echo " "
echo ' {|<>|} BEGIN (Parallel)|(Output) {|<>|} '
echo "________________________________________ "
/usr/bin/time parallel --will-cite --jobs 5 -- < $TMP/tester.sh
echo "________________________________________ "
echo ' {|<>|} *END* (Parallel)|(Output) {|<>|} '
rm -Rf $TMP
