
# Documentation for Red Hat OpenShift.io

This is the Git repository for documentation related to Red Hat OpenShift.io, the SaaS for developers. The documentation is published at https://docs.openshift.io/.


## Building the Documentation

The docs are built automatically for every PR and upon every push to the *master* branch. You can then preview the built docs at https://docs.prod-preview.openshift.io/. Build status: [![Build Status](https://ci.centos.org/view/Devtools/job/devtools-fabric8-online-docs-build-master/badge/icon)](https://ci.centos.org/view/Devtools/job/devtools-fabric8-online-docs-build-master/)

> **Validating Mark-up**
>
> You need to have `asciidoctor` and `xmllint` installed. To validate the mark-up used in all docs in the repo, run the following:
>
>```
>$ scripts/validate_guides.sh
>```


### Building Locally

There are three ways to build and preview the docs.


#### 1) Using Plain AsciiDoctor

You need `asciidoctor` installed. To build a specific guide, run:

```
$ cd docs/<guide>/
$ asciidoctor --attribute imagesdir=topics/images master.adoc
$ <www-browser-of-choice> master.html
```


#### 2) Using the build_guides.sh Script

You need `asciidoctor` installed. To build all guides, run:

```
$ scripts/build_guides.sh
$ <www-browser-of-choice> html/*.html
```

HTML versions are built into the `html/` directory.


#### 3) Using containers

You need the `docker` daemon running on your machine. To build the whole docs site, including the landing page, to test the automated building process, run:

```
$ export CICO_LOCAL=local
$ sudo ./cico_build_deploy.sh
```

Following a successful local build, the docs will be available for preview on localhost:

```
$ <www-browser-of-choice> http://127.0.0.1:2015/
```


### Deploying the Documentation on OpenShift

```
$ export DOCS_VERSION=$(curl -L http://central.maven.org/maven2/io/fabric8/apps/fabric8-online-docs-app/maven-metadata.xml | grep '<latest' | cut -f2 -d">" | cut -f1 -d"<")

$ oc apply -f http://central.maven.org/maven2/io/fabric8/apps/fabric8-online-docs-app/$DOCS_VERSION/fabric8-online-docs-app-$DOCS_VERSION-openshift.yml
```
