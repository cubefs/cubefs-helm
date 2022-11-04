# cubefs-helm Makefile

package: lint
	cp README.md cubefs/ && helm package cubefs && rm cubefs/README.md

lint:
	helm lint ./cubefs

.PHONY: package lint
