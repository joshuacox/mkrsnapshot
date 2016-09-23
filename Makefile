.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs

rsnapshot: run

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

build: INVENTORY SNAPSHOT_DIR BACKUP_DIR builddocker

# run a plain container
run: rm build rsnapshotCID

# alias
r: rsnapshot

rsnapshotCID:
	$(eval NAME := $(shell cat NAME))
	$(eval TAG := $(shell cat TAG))
	$(eval KEYS := $(shell cat KEYS))
	$(eval BACKUP_DIR := $(shell cat BACKUP_DIR))
	$(eval SNAPSHOT_DIR := $(shell cat SNAPSHOT_DIR))
	$(eval INVENTORY := $(shell cat INVENTORY))
	@docker run --name=$(NAME) \
	-d \
	--cidfile="rsnapshotCID" \
	-v $(KEYS):/root/keys \
	-v $(INVENTORY):/root/inventory \
	-v $(BACKUP_DIR):/backups \
	-v $(SNAPSHOT_DIR):/snapshot \
	-v `pwd`/rsnapshot.conf:/etc/rsnapshot.conf \
	-t $(TAG)

builddocker:
	/usr/bin/time -v docker build -t `cat TAG` .

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
	cp -i inventory.example $(HOME)/inventory
	echo $(HOME)/inventory > INVENTORY
	echo $(HOME)/backups > BACKUP_DIR
	echo $(HOME)/snapshots > SNAPSHOT_DIR

new: NEW_USERNAME NEW_HOST NEW_PORT NEW_PATH INVENTORY BACKUP_DIR SNAPSHOT_DIR
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NEW_USERNAME := $(shell cat NEW_USERNAME))
	$(eval NEW_HOST := $(shell cat NEW_HOST))
	$(eval NEW_PORT := $(shell cat NEW_PORT))
	$(eval NEW_PATH := $(shell cat NEW_PATH))
	$(eval INVENTORY := $(shell cat INVENTORY))
	@grep '^#' $(INVENTORY) $(TMP)/header
	@grep -v '^#' $(INVENTORY) $(TMP)/newinventory
	@echo "$(NEW_USERNAME),$(NEW_HOST),$(NEW_PORT),$(NEW_PATH)" >> $(TMP)/newinventory
	@cp $(TMP)header $(TMP)/uniqinventory
	@cat $(TMP)/newinventory | sort |uniq >> $(TMP)/uniqinventory
	-@diff $(TMP)/uniqinventory $(INVENTORY)
	mv -i $(TMP)/uniqinventory $(INVENTORY)
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
