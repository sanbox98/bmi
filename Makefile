SHELL := /bin/bash
GOBIN=$(shell which go)
GOBUILD=$(GOBIN) build

DOCKERBIN = $(shell which docker)

DEBUG_FLAGS := ""
STATIC_FLAGS = '-w -extldflags "-static"'
ifneq ($(origin DEBUG), undefined)
	STATIC_FLAGS = '-extldflags "-static"'
	# Get the golang version and coresponding gcflags pattern
	goVerStr := $(shell go version | awk '{split($$0,a," ")}; {print a[3]}')
	goVerNum := $(shell echo $(goVerStr) | awk '{split($$0,a,"go")}; {print a[2]}')
	goVerMajor := $(shell echo $(goVerNum) | awk '{split($$0, a, ".")}; {print a[1]}')
	goVerMinor := $(shell echo $(goVerNum) | awk '{split($$0, a, ".")}; {print a[2]}')
	gcflagsPattern := $(shell ( [ $(goVerMajor) -ge 1 ] && [ ${goVerMinor} -ge 10 ] ) && echo 'all=' || echo '')

	# @echo $(goVerStr)
	DEBUG_FLAGS = "$(gcflagsPattern)-l -N"
endif


calculator:
	cd ./calculator; $(GOBUILD) -ldflags $(STATIC_FLAGS) -gcflags $(DEBUG_FLAGS)

docker.calculator: calculator
	mv ./calculator/calculator ./k8s/
	cd ./k8s; $(DOCKERBIN) build -t bmi/calculator:v1 -f ./Dockerfile.calculator .

k8s.calculator: docker.calculator
	./scripts/distribute-image.sh bmi/calculator:v1
	-kubectl delete -f ./k8s/calculator.yaml
	kubectl apply -f ./k8s/calculator.yaml
