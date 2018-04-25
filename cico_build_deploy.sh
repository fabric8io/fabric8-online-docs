#!/usr/bin/env bash

GENERATOR_DOCKER_HUB_USERNAME=openshiftioadmin
REGISTRY_URI="push.registry.devshift.net"
REGISTRY_NS="fabric8io"
REGISTRY_IMAGE="fabric8-online-docs"
BUILDER_IMAGE="docs-builder"
BUILDER_CONT="docs-builder-container"
DEPLOY_IMAGE="docs-deploy"
DEPLOY_CONT="docs-deploy-container"

if [ "$TARGET" = "rhel" ]; then
    REGISTRY_URL=${REGISTRY_URI}/osio-prod/${REGISTRY_NS}/${REGISTRY_IMAGE}
    DOCKERFILE_DEPLOY="Dockerfile.deploy.rhel"
else
    REGISTRY_URL=${REGISTRY_URI}/${REGISTRY_NS}/${REGISTRY_IMAGE}
    DOCKERFILE_DEPLOY="Dockerfile.deploy"
fi

TARGET_DIR="html"

function docker_login() {
    local USERNAME=$1
    local PASSWORD=$2
    local REGISTRY=$3

    if [ -n "${USERNAME}" ] && [ -n "${PASSWORD}" ]; then
        docker login -u ${USERNAME} -p ${PASSWORD} ${REGISTRY}
    fi
}

function tag_push() {
    local TARGET_IMAGE=$1

    docker tag ${DEPLOY_IMAGE} ${TARGET_IMAGE}
    docker push ${TARGET_IMAGE}
}

# Exit on error
set -ex

if [ -z $CICO_LOCAL ]; then
    [ -f jenkins-env ] && cat jenkins-env | grep -e PASS -e GIT -e DEVSHIFT > inherit-env
    [ -f inherit-env ] && . inherit-env

    # We need to disable selinux for now, XXX
    /usr/sbin/setenforce 0 || :

    # Get all the deps in
    yum -y install docker make git
    service docker start
fi

#CLEAN UP BUILDER CONTAINER
docker ps | grep -q ${BUILDER_CONT} && docker stop ${BUILDER_CONT}
docker ps -a | grep -q ${BUILDER_CONT} && docker rm ${BUILDER_CONT}

#REMOVE DIR WITH OLD BUILT DOCS IF IT EXISTS
if [ -d $TARGET_DIR ]; then rm -rf ${TARGET_DIR}/; fi

#CREATE A FRESH DIR FOR BUILT DOCS TO BE PUT INTO
mkdir -pm 777 ${TARGET_DIR}

#BUILD BUILDER IMAGE
docker build -t ${BUILDER_IMAGE} -f Dockerfile.build .

#RUN BUILDER CONTAINER ONCE, THUS BUILDING THE DOCS
docker run --rm --name=${BUILDER_CONT} -it --volume=$(pwd)/${TARGET_DIR}:/${TARGET_DIR}:Z ${BUILDER_IMAGE}

#LOGIN IS REQUIRED FOR BUILDING ON RHEL
if [ -z "$CICO_LOCAL" ]; then
  docker_login "${DEVSHIFT_USERNAME}" "${DEVSHIFT_PASSWORD}" "${REGISTRY_URI}"
fi

#BUILD DEPLOY IMAGE
docker build -t ${DEPLOY_IMAGE} -f "${DOCKERFILE_DEPLOY}" .

#PUSH
if [ -z $CICO_LOCAL ]; then
    TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})
    tag_push "${REGISTRY_URL}:${TAG}"
    tag_push "${REGISTRY_URL}:latest"
fi

#SERVE DOCS WHEN ON LOCAL
if [ ! -z $CICO_LOCAL ]; then

  #CLEAN UP OLD DEPLOY (CADDY) CONTAINERS
  docker ps | grep -q $DEPLOY_CONT && docker stop $DEPLOY_CONT
  docker ps -a | grep -q $DEPLOY_CONT && docker rm $DEPLOY_CONT

  #RUN THE DEPLOY (CADDY) CONTAINER
  docker run --detach=true --name $DEPLOY_CONT --publish 2015:2015 $DEPLOY_IMAGE && \
    echo "Docs are now available for local preview at http://127.0.0.1:2015/"    || \
    echo "Local deployment of docs failed."
fi
