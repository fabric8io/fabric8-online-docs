#!/usr/bin/env bash

GENERATOR_DOCKER_HUB_USERNAME=openshiftioadmin
REGISTRY_URI="push.registry.devshift.net"
REGISTRY_NS="fabric8io"
REGISTRY_IMAGE="fabric8-online-docs"
REGISTRY_URL=${REGISTRY_URI}/${REGISTRY_NS}/${REGISTRY_IMAGE}
BUILDER_IMAGE="docs-builder"
BUILDER_CONT="docs-builder-container"
DEPLOY_IMAGE="docs-deploy"
DEPLOY_CONT="docs-deploy-container"

TARGET_DIR="html"

function tag_push() {
    TARGET_IMAGE=$1
    USERNAME=$2
    PASSWORD=$3
    REGISTRY=$4

    docker tag ${DEPLOY_IMAGE} ${TARGET_IMAGE}
    if [ -n "${USERNAME}" ] && [ -n "${PASSWORD}" ]; then
        docker login -u ${USERNAME} -p ${PASSWORD} ${REGISTRY}
    fi
    docker push ${TARGET_IMAGE}
}

# Exit on error
set -ex

if [ -z $CICO_LOCAL ]; then
    [ -f jenkins-env ] && cat jenkins-env | grep -e PASS -e GIT -e DEVSHIFT > inherit-env
    [ -f inherit-env ] && . inherit-env

    # We need to disable selinux for now, XXX
    /usr/sbin/setenforce 0

    # Get all the deps in
    yum -y install docker make git

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
mkdir -m 777 ${TARGET_DIR}

#BUILD BUILDER IMAGE
docker build -t ${BUILDER_IMAGE} -f Dockerfile.build .

#RUN BUILDER CONTAINER ONCE, THUS BUILDING THE DOCS
docker run --rm --name=${BUILDER_CONT} --tty=true --volume=$(pwd)/${TARGET_DIR}:/${TARGET_DIR}:Z ${BUILDER_IMAGE}

#BUILD DEPLOY IMAGE
docker build -t ${DEPLOY_IMAGE} -f Dockerfile.deploy .

#PUSH
if [ -z $CICO_LOCAL ]; then
    TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})
    tag_push "${REGISTRY_URL}:${TAG}" ${DEVSHIFT_USERNAME} ${DEVSHIFT_PASSWORD} ${REGISTRY_URI}
    tag_push "${REGISTRY_URL}:latest" ${DEVSHIFT_USERNAME} ${DEVSHIFT_PASSWORD} ${REGISTRY_URI}
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
