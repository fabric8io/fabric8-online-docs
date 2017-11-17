# Documentation for Red Hat OpenShift.io

This is the Git repository for documentation related to Red Hat OpenShift.io, the SaaS for developers. The documentation will be published at https://docs.openshift.io/.


## Building the Documentation

The docs are built automatically upon every push to the *master* branch. You can then preview the built docs at https://docs.prod-preview.openshift.io/.


### Building Locally

There are three ways to build and preview the docs.


#### Using Plain AsciiDoctor

You need `asciidoctor` installed. To build a specific guide, run:

```
$ cd docs/<guide>/
$ asciidoctor --attribute imagesdir=topics/images master.adoc
$ <www-browser-of-choice> master.html
```


#### Using the build_guides.sh Script

You need `asciidoctor` and `asciidoctor-pdf` installed. To build all guides, including PDF versions, run:

```
$ scripts/build_guides.sh
$ <www-browser-of-choice> html/*.html
```

Both HTML and PDF versions are built into the `html/` directory.


#### Using the Dockerfiles

You need the `docker` daemon running on your machine. To build the whole docs site, including the landing page, to test the automated building process, run:

```
$ export CICO_LOCAL=local
$ ./cico_build_deploy.sh
```

Following a successful build, start serving the docs on localhost by executing:

```
$ docker run --detach=true --name=docs-server --publish=2015:2015 documentation-deploy
$ <www-browser-of-choice> http://127.0.0.1:2015/
```


### Deploying the Documentation on OpenShift

```
$ export DOCS_VERSION=$(curl -L http://central.maven.org/maven2/io/fabric8/apps/fabric8-online-docs-app/maven-metadata.xml | grep '<latest' | cut -f2 -d">" | cut -f1 -d"<")

$ oc apply -f http://central.maven.org/maven2/io/fabric8/apps/fabric8-online-docs-app/$DOCS_VERSION/fabric8-online-docs-app-$DOCS_VERSION-openshift.yml
```
