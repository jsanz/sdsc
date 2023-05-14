default: help

EXECUTABLES = printf awk docker
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

## This help screen
help:
	@printf "Available targets:\n\n"
	@awk '/^[a-zA-Z\-_0-9%:\\]+/ { \
	  helpMessage = match(lastLine, /^## (.*)/); \
	  if (helpMessage) { \
	    helpCommand = $$1; \
	    helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
	gsub("\\\\", "", helpCommand); \
	gsub(":+$$", "", helpCommand); \
	printf "  \x1b[32;01m%-15s\x1b[0m %s\n", helpCommand, helpMessage; \
	} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) 
	@printf "\n"

## Remove the docker image from the system
clean:
	@docker image rm sdsc

## Build the docker image
build:
	@docker build -t sdsc .

## Run the image mounting this folder at /sdsc
run: build
	@docker run --rm -p 8888:8888 -v $${PWD}:/sdsc sdsc:latest

## Run the image without mounting this folder
run-isolated:
	@docker run --rm -p 8888:8888 sdsc:latest
