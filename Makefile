.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs

rsnapshot: run

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

build: REMOTE_PATH REMOTE_PORT REMOTE_USER REMOTE_HOST builddocker

# run a plain container
run: build rundocker

rundocker: runprod

runprod: rsnapshotCID

rsnapshotCID:
	$(eval NAME := $(shell cat NAME))
	$(eval TAG := $(shell cat TAG))
	$(eval REMOTE_USER := $(shell cat REMOTE_USER))
	$(eval REMOTE_HOST := $(shell cat REMOTE_HOST))
	$(eval REMOTE_PORT := $(shell cat REMOTE_PORT))
	$(eval REMOTE_PATH := $(shell cat REMOTE_PATH))
	$(eval KEYS := $(shell cat KEYS))
	@docker run --name=$(NAME) \
	--cidfile="rsnapshotCID" \
	-d \
	-e "REMOTE_PATH=$(REMOTE_PATH)" \
	-e "REMOTE_PORT=$(REMOTE_PORT)" \
	-e "REMOTE_USER=$(REMOTE_USER)" \
	-e "REMOTE_HOST=$(REMOTE_HOST)" \
	-v $(KEYS):/root/keys \
	-t $(TAG)

builddocker:
	/usr/bin/time -v docker build -t `cat TAG` .

kill:
	-@docker kill `cat rsnapshotCID`

rm-image:
	-@docker rm `cat rsnapshotCID`
	-@rm rsnapshotCID

rm: kill rm-image

clean: rm

enter:
	docker exec -i -t `cat rsnapshotCID` /bin/bash

logs:
	docker logs -f `cat rsnapshotCID`

REMOTE_PATH:
	@while [ -z "$$REMOTE_PATH" ]; do \
		read -r -p "Enter the REMOTE_PATH you wish to associate with this container [REMOTE_PATH]: " REMOTE_PATH; echo "$$REMOTE_PATH">>REMOTE_PATH; cat REMOTE_PATH; \
	done ;

REMOTE_PORT:
	@while [ -z "$$REMOTE_PORT" ]; do \
		read -r -p "Enter the REMOTE_PORT you wish to associate with this container [REMOTE_PORT]: " REMOTE_PORT; echo "$$REMOTE_PORT">>REMOTE_PORT; cat REMOTE_PORT; \
	done ;

REMOTE_HOST:
	@while [ -z "$$REMOTE_HOST" ]; do \
		read -r -p "Enter the REMOTE_HOST you wish to associate with this container [REMOTE_HOST]: " REMOTE_HOST; echo "$$REMOTE_HOST">>REMOTE_HOST; cat REMOTE_HOST; \
	done ;

REMOTE_USER:
	@while [ -z "$$REMOTE_USER" ]; do \
		read -r -p "Enter the REMOTE_USER you wish to associate with this container [REMOTE_USER]: " REMOTE_USER; echo "$$REMOTE_USER">>REMOTE_USER; cat REMOTE_USER; \
	done ;
