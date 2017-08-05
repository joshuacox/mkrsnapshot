.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs keyscan showinv tester test

rsnapshot: run

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

build: RSNAPSHOT_PERIOD INVENTORY SNAPSHOT_DIR BACKUP_DIR PARALLEL_JOBS BWLIMIT builddocker

pull: RSNAPSHOT_PERIOD INVENTORY SNAPSHOT_DIR BACKUP_DIR PARALLEL_JOBS BWLIMIT pulldocker

# run a plain container
run: rm RSNAPSHOT_PERIOD INVENTORY SNAPSHOT_DIR BACKUP_DIR PARALLEL_JOBS BWLIMIT rsnapshotCID

# alias
r: rsnapshot

rsnapshotCID:
	$(eval NAME := $(shell cat NAME))
	$(eval TAG := $(shell cat TAG))
	$(eval KEYS := $(shell cat KEYS))
	$(eval BWLIMIT := $(shell cat BWLIMIT))
	$(eval BACKUP_DIR := $(shell cat BACKUP_DIR))
	$(eval SNAPSHOT_DIR := $(shell cat SNAPSHOT_DIR))
	$(eval INVENTORY := $(shell cat INVENTORY))
	$(eval PARALLEL_JOBS := $(shell cat PARALLEL_JOBS))
	$(eval RSNAPSHOT_PERIOD := $(shell cat RSNAPSHOT_PERIOD))
	@docker run --name=$(NAME) \
	-d \
	--cidfile="rsnapshotCID" \
	-v $(KEYS):/root/keys \
	-v $(INVENTORY):/root/inventory \
	-e PARALLEL_JOBS=$(PARALLEL_JOBS) \
	-e BWLIMIT=$(BWLIMIT) \
	-e RSNAPSHOT_PERIOD=$(RSNAPSHOT_PERIOD) \
	-v $(BACKUP_DIR):/backups \
	-v $(SNAPSHOT_DIR):/snapshot \
	-v `pwd`/rsnapshot.conf:/etc/rsnapshot.conf \
	-t $(TAG)

builddocker:
	/usr/bin/time -v docker build -t `cat TAG` .

pulldocker:
	/usr/bin/time -v docker pull `cat TAG` .

kill:
	-@docker kill `cat rsnapshotCID`

rm-image:
	-@docker rm `cat rsnapshotCID`
	-@rm rsnapshotCID

rm: kill rm-image

enter:
	docker exec -i -t `cat rsnapshotCID` /bin/bash

logs:
	docker logs -f `cat rsnapshotCID`

PARALLEL_JOBS:
	@while [ -z "$$PARALLEL_JOBS" ]; do \
		read -r -p "Enter the number of PARALLEL_JOBS you wish to associate with this container [PARALLEL_JOBS]: " PARALLEL_JOBS; echo "$$PARALLEL_JOBS">>PARALLEL_JOBS; cat PARALLEL_JOBS; \
	done ;

INVENTORY:
	@while [ -z "$$INVENTORY" ]; do \
		read -r -p "Enter the INVENTORY you wish to associate with this container [INVENTORY]: " INVENTORY; echo "$$INVENTORY">>INVENTORY; cat INVENTORY; \
	done ;

BACKUP_DIR:
	@while [ -z "$$BACKUP_DIR" ]; do \
		read -r -p "Enter the BACKUP_DIR directory you wish to associate with this container [BACKUP_DIR]: " BACKUP_DIR; echo "$$BACKUP_DIR">>BACKUP_DIR; cat BACKUP_DIR; \
	done ;

SNAPSHOT_DIR:
	@while [ -z "$$SNAPSHOT_DIR" ]; do \
		read -r -p "Enter the SNAPSHOT_DIR directory you wish to associate with this container [SNAPSHOT_DIR]: " SNAPSHOT_DIR; echo "$$SNAPSHOT_DIR">>SNAPSHOT_DIR; cat SNAPSHOT_DIR; \
	done ;

# Aliases

rsnapshot: run

clean: rm

example:
	cp KEYS.example KEYS
	cp -i inventory.example $(HOME)/inventory
	echo $(HOME)/inventory > INVENTORY
	echo $(HOME)/backups > BACKUP_DIR
	echo $(HOME)/snapshots > SNAPSHOT_DIR
	echo 512 > BWLIMIT
	echo 1 > PARALLEL_JOBS
	echo 'daily' > RSNAPSHOT_PERIOD

new: NEW_USERNAME NEW_HOST NEW_PORT NEW_PATH INVENTORY BACKUP_DIR SNAPSHOT_DIR
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NEW_USERNAME := $(shell cat NEW_USERNAME))
	$(eval NEW_HOST := $(shell cat NEW_HOST))
	$(eval NEW_PORT := $(shell cat NEW_PORT))
	$(eval NEW_PATH := $(shell cat NEW_PATH))
	$(eval INVENTORY := $(shell cat INVENTORY))
	-grep '^#' $(INVENTORY) > $(TMP)/uniqinventory
	grep -v '^#' $(INVENTORY) > $(TMP)/newinventory
	echo "$(NEW_USERNAME),$(NEW_HOST),$(NEW_PORT),$(NEW_PATH)" >> $(TMP)/newinventory
	sort $(TMP)/newinventory | uniq >> $(TMP)/uniqinventory
	grep . $(TMP)/uniqinventory > $(TMP)/clean
	-diff $(TMP)/clean $(INVENTORY)
	mv -i $(TMP)/clean $(INVENTORY)
	-@rm -Rf $(TMP)
	-@ rm NEW_USERNAME NEW_HOST NEW_PORT NEW_PATH

NEW_USERNAME:
	@while [ -z "$$NEW_USERNAME" ]; do \
		read -r -p "Enter the NEW_USERNAME directory you wish to associate with this new backup [NEW_USERNAME]: " NEW_USERNAME; echo "$$NEW_USERNAME">>NEW_USERNAME; cat NEW_USERNAME; \
	done ;

NEW_HOST:
	@while [ -z "$$NEW_HOST" ]; do \
		read -r -p "Enter the NEW_HOST directory you wish to associate with this new backup [NEW_HOST]: " NEW_HOST; echo "$$NEW_HOST">>NEW_HOST; cat NEW_HOST; \
	done ;

NEW_PORT:
	@while [ -z "$$NEW_PORT" ]; do \
		read -r -p "Enter the NEW_PORT directory you wish to associate with this new backup [NEW_PORT]: " NEW_PORT; echo "$$NEW_PORT">>NEW_PORT; cat NEW_PORT; \
	done ;

NEW_PATH:
	@while [ -z "$$NEW_PATH" ]; do \
		read -r -p "Enter the NEW_PATH directory you wish to associate with this new backup [NEW_PATH]: " NEW_PATH; echo "$$NEW_PATH">>NEW_PATH; cat NEW_PATH; \
	done ;

RSNAPSHOT_PERIOD:
	@while [ -z "$$RSNAPSHOT_PERIOD" ]; do \
		read -r -p "Enter the RSNAPSHOT_PERIOD you wish to associate with this new backup [hourly,daily,weekly]: " RSNAPSHOT_PERIOD; echo "$$RSNAPSHOT_PERIOD">>RSNAPSHOT_PERIOD; cat RSNAPSHOT_PERIOD; \
	done ;

BWLIMIT:
	@while [ -z "$$BWLIMIT" ]; do \
		read -r -p "Enter the bandwidth limit you wish to use, in K [BWLIMIT]: " BWLIMIT; echo "$$BWLIMIT">>BWLIMIT; cat BWLIMIT; \
	done ;

test: tester

tester:
	/bin/bash tester.sh

keyscan:
	/bin/bash keyscan.sh
