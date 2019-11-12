# chubaofs-helm Makefile 

all: build

lint:
	helm lint ./chubaofs

build: lint
	helm package ./chubaofs

.PHONY: all lint build
