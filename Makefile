# chubaofs-helm Makefile 

package: lint
	cp README.md chubaofs/ && helm package chubaofs && rm chubaofs/README.md 

lint:
	helm lint ./chubaofs

.PHONY: package 
