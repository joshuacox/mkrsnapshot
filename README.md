# mkrsnapshot

Make an rsnapshot PDQ

KISS backup method,  I like to use at least two backup methods.
One can be complex, but I need one to be very simple stupid and bulletproof.
So I adapted some old shell scripts into a docker container with a
shellscript that reads a CSV inventory file and does a simple rsnapshot based backup.

### Usage

```
make rsnapshot
```

it will prompt you for a path to your ssh keys, and ssh information about the remote host.

### Example

```
make example
```

will setup your home folder as the location for the inventory file,
and both the backups and snapshots directories, then simply edit the inventory file (or use `make new` ) inside your home directory and  `make rsnapshot`.

Afterwards look inside of `~/backups` which contains backups.

And `~/snapshots` which contains the snapshot hardlinks.

#### WARNING
due to the nature of [hardlinks](http://linuxgazette.net/105/pitcher.html) these two folders must be placed on the same filesystem.


### Inventory

The inventory file is merely a CSV file with username, hostname (or IP), port, and a path:

```
#USERNAME,IPorFQDN,PORT,PATH
username,192.168.51.186,2222,/path
root,example.com,2022,/etc
```

you will be prompted for a location of this file, or you can copy the example and use it here:

```
cp -i inventory.example inventory
echo `pwd`/inventory > INVENTORY
```

I prefer to keep it outside of the git directory though. How about your home directory?

```
cp -i inventory.example $HOME/inventory
echo $HOME/inventory > INVENTORY
```

Or just use the `make example` from above, but I wanted to give you an idea of how to change the defaults.

### Test

```
make test
```

will test your inventory and attempt to contact each of the ssh servers and print out `uname -a` for them

### New

```
make new
```

This command will prompt you for all the necessary components of another line in the inventory and write another line to your inventory,
it will sort and uniq your inventory to prevent duplicates

### Details

Not much to explain here, everything happens in `start.sh`

and the meat of the whole thing is really done by this for loop:

```
for i in $(cat $INVENTORY);do echo $i|cut --output-delimiter=' ' -f1,2,3,4 -d','|awk '{print "rsync -ave \"ssh -p " $3 "\" --relative " $1 "@" $2 ":" $4 " /backups/" $2 "/" }'>>/tmp/sync.sh ;done
```

### GNU Parallel

  O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
    ;login: The USENIX Magazine, February 2011:42-47.
