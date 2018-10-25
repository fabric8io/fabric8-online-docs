#!/usr/bin/env bash

REGISTRY_URI="quay.io"
REGISTRY_NS="fabric8io"
REGISTRY_IMAGE="fabric8-online-docs"
BUILDER_IMAGE="docs-builder"
BUILDER_CONT="docs-builder-container"
DEPLOY_IMAGE="docs-deploy"
DEPLOY_CONT="docs-deploy-container"

if [ "$TARGET" = "rhel" ]; then
    REGISTRY_URL=${REGISTRY_URI}/openshiftio/rhel-${REGISTRY_NS}-${REGISTRY_IMAGE}
    DOCKERFILE_DEPLOY="Dockerfile.deploy.rhel"
else
    REGISTRY_URL=${REGISTRY_URI}/openshiftio/${REGISTRY_NS}-${REGISTRY_IMAGE}
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

function addCommentToPullRequest() {
    local snapshotImageName=$1
    local message="@${ghprbPullAuthorLogin} snapshot docs image is available. Try \`docker pull ${snapshotImageName}\`, run the image using \`docker run -it -p 4000:8080 ${snapshotImageName}\`. Docs are now available for preview at \`http://127.0.0.1:4000\` Thanks"

    pr="${ghprbPullId}"
    project="${ghprbGhRepository}"
    url="https://api.github.com/repos/${project}/issues/${pr}/comments"

    set +x
    echo curl -X POST -s -L -H "Authorization: XXXX|base64 --decode)" ${url} -d "{\"body\": \"${message}\"}"
    curl -X POST -s -L -H "Authorization: token $(echo ${FABRIC8_HUB_TOKEN}|base64 --decode)" ${url} -d "{\"body\": \"${message}\"}"
    set -x
}

# Exit on error
set -ex

eval "$(./env-toolkit load -f jenkins-env.json \
        FABRIC8_HUB_TOKEN \
        QUAY_USERNAME \
        QUAY_PASSWORD \
        ghprbGhRepository \
        ghprbPullAuthorLogin \
        ghprbPullId \
        BUILD_ID)"

# We need to disable selinux for now, XXX
/usr/sbin/setenforce 0 || :

# Get all the deps in
yum -y install docker make git
service docker start

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

#BUILD DEPLOY IMAGE
docker build -t ${DEPLOY_IMAGE} -f "${DOCKERFILE_DEPLOY}" .

#LOGIN IS REQUIRED FOR BUILDING ON RHEL
docker_login "${QUAY_USERNAME}" "${QUAY_PASSWORD}" "${REGISTRY_URI}"

#PUSH
TAG="SNAPSHOT-PR-${ghprbPullId}-${BUILD_ID}"
tag_push "${REGISTRY_URL}:${TAG}"
addCommentToPullRequest "${REGISTRY_URL}:${TAG}"