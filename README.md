# Develop Body Mass Index(BMI) via go-chassis


### Play with kubernetes
The docker builds & kubernetes orchestrations are already there in the `Makefile`. There are 3 stages from binary builds to kubernetes deployments:
- build binaries: `make $target`, for example `make calculator`, this will build the calculator binary
- build docker images: `make docker.$target`, for example `make docker.calculator`, this will build the calculator image
- deploy image to k8s cluster: `make k8s.$target`, for example `make k8s.calculator`, this will deploy the calculator to the kubernetes cluster by a service and a deployment

Handle all by `make`:
- `make bin`: build all the binaries
- `make docker`: execute `make bin`, then build the docker images
- `make k8s`: execute `make docker`, then deploy the newly built image to the kubernetes cluster
