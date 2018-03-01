# Contributing to the documentation

## Repository structure

Briefly, this is what you need to know about the documentation repository structure before contributing:

* The documentation is module-based, which means most sections are individual modules. These modules are available in the */docs/topics/modules/* folder.
* The modules are linked together to form a chapter, document, or guide using assemblies. These assemblies are asciidoc files in the */docs/topics/* folder. For example, the */docs/topics/getting-started-guide.adoc* file is the main assembly for the Getting Started Guide and links to other, smaller assemblies for parts or chapters within the guide.
* Module files naming conventions closely follow the title of the corresponding section. For example, a section in the Getting Started document with the title *Working with pipelines* is named **working_with_pipelines.adoc** in the *modules* folder. In some cases, this is not a direct match, so to confirm the name of the asciidoc file for a section, click the section title and the ID after the *#* in the URL is the name of the module file. For example, a URL such as https://docs.openshift.io/getting-started-guide.html#viewing_build_pipeline_oso has a slightly different title but the ID after the hash symbol (**viewing_build_pipeline_oso**) is the name of the file.

## Conventions and style guidelines

To get started quickly, we recommend reviewing the following conventions that are relevant for this documentation suite:

**Writing conventions**

* For instructions, state the location, then action and subject. For example:
  * Incorrect: *Click OK in the XYZ tab to continue.*
  * Correct: *In the XYZ tab, click OK to continue.*
  * Use gerunds in titles when possible. For example:
    * Incorrect: *1.1 Create a new project*
    * Correct: *1.1 Creating a new project*
* All titles should be in sentence case. Exceptions for words that are proper nouns. For example:
  * Incorrect: *1.2 Configuring Your Che Workspace*
  * Correct: *1.2 Configuring your Che workspace*
* URLs must be bared in the text, not hidden. For example:
  * Incorrect: *Navigate to the [Red Hat website](www.redhat.com).* 
  * Correct: *Navigate to (www.redhat.com).*
  
**Markup conventions**  

* TBD 
  
For comprehensive references for documentation conventions, see the following:

  * The IBM Style Guide. A subset of this guide is available [here](https://www.ibm.com/developerworks/library/styleguidelines/).
  * The [Red Hat Asciidoc Markup conventions](https://redhat-documentation.github.io/asciidoc-markup-conventions/).
  <!-- * The [CCS Documentation Conventions][url here when available] UNCOMMENT THIS WHEN READY-->

## Editing the documentation

To edit the documentation:

1. Ensure that an issue with the details of the problem are logged at https://github.com/fabric8io/fabric8-online-docs/issues for context and assign it to yourself.

2. Clone the documentation repository and make the relevant changes in a branch named after the issue you are working on.

3. Locally build and test the changes. For details on the instructions and tools to do this, see [Locally building the documentation](#locally-building-the-documentation).

3. After the local builds are successful, commit your changes and create a PR for the fixes. In the assignee field, select one of the writers to do a quick review before merging your changes. You can tag Robert Kratky, Misha Husnain Ali, or Preeti Chandrashekar as reviewers.

4. For each push to the *master* branch and each PR, a preview build of the documentation is created and available at https://docs.prod-preview.openshift.io/. Build status: [![Build Status](https://ci.centos.org/view/Devtools/job/devtools-fabric8-online-docs-build-master/badge/icon)](https://ci.centos.org/view/Devtools/job/devtools-fabric8-online-docs-build-master/). The creator of the PR and reviewers can use this build for testing, which is why it is essential to test your changes locally before creating the PR.

5. When reviewed, and after any changes necessary are completed, the PR is merged into the documentation.

## Locally building the documentation

After making changes to the documentation, you can locally build and test the changes. 

### Step 1: Validating markup

After making changes, run the validate script to test the asciidoc markup used in this repository. 

1. Ensure that `asciidoctor` and `xmllint` are installed on your machine.
2. Run the following script:
```
$ scripts/validate_guides.sh
```

### Step 2: Build the docs

After validating the documentation, you can locally build the docs in one of three ways:

**1) Build using AsciiDoctor**

To build a specific guide:

1. Navigate to the target guide's folder:
```
$ cd docs/<guide>/
```

2. Run the build command:
```
$ asciidoctor --attribute imagesdir=topics/images master.adoc
```

3. View the built guide in a browser:
``` 
$ <www-browser-of-choice> master.html
```


**2) Build using a script**

1. To build all the guides, run the following script:
```
$ scripts/build_guides.sh
```

2. View the results of the build in a browser:
```
$ <www-browser-of-choice> html/*.html
```

HTML versions are built into the `html/` directory.


**3) Build using containers**

This method requires the `docker` daemon running on your machine. 

1. To build the whole docs site, including the landing page, to test the automated building process, run:
```
$ export CICO_LOCAL=local
$ sudo ./cico_build_deploy.sh
```

2. After a successful build, preview the documentation on localhost:
```
$ <www-browser-of-choice> http://127.0.0.1:2015/
```


### Deploying the documentation on OpenShift

Use the following commands to deploy the documentation on OpenShift:
```
$ export DOCS_VERSION=$(curl -L http://central.maven.org/maven2/io/fabric8/apps/fabric8-online-docs-app/maven-metadata.xml | grep '<latest' | cut -f2 -d">" | cut -f1 -d"<")

$ oc apply -f http://central.maven.org/maven2/io/fabric8/apps/fabric8-online-docs-app/$DOCS_VERSION/fabric8-online-docs-app-$DOCS_VERSION-openshift.yml
```