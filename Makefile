default: help

PYTHON ?= python3
SHELL := /bin/bash

EXECUTABLES = printf awk docker $(PYTHON)
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
docker/clean:
	@docker image rm sdsc

## Build the docker image
docker/build:
	@docker build -t sdsc .

## Run the image mounting this folder at /sdsc
docker/run: docker/build
	@docker run -it --rm --name sdsc -p 8888:8888 -v $${PWD}:/sdsc sdsc:latest

## Run the image without mounting this folder
docker/run-isolated:
	@docker run --rm -p 8888:8888 sdsc:latest

## Creates a new virtual environment
python/create-env:
	@if [ ! -d env ]; then $(PYTHON) -m venv env; \
		else echo "Virtual environment already created"; \
		fi;

## Cleans the virtual environment
python/clean-env:
	rm -rf env

## Builds and installs the necessary python packages
python/build: python/create-env
	source env/bin/activate && pip install -r requirements.txt

## Runs the Jupyter Notebook
python/run: python/build
	source env/bin/activate && jupyter notebook --NotebookApp.token='sdsc' --NotebookApp.password=''

## Generates an HTML export of the notebook
python/convert: python/build
	source env/bin/activate && jupyter nbconvert 2023-foundations-of-geospatial.ipynb --to slides
