.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

build: INVENTORY SNAPSHOT_DIR BACKUP_DIR builddocker

# run a plain container
run: rm build rsnapshotCID

rsnapshotCID:
	$(eval NAME := $(shell cat NAME))
	$(eval TAG := $(shell cat TAG))
	$(eval KEYS := $(shell cat KEYS))
	$(eval BACKUP_DIR := $(shell cat BACKUP_DIR))
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
