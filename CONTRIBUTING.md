# Contributing to the documentation

## Editing the documentation

To edit the documentation:

1. Learn about the general repository structure in the [Repository structure HTML](./README.md#repository-structure) section.

2. Read the writing and markup conventions summary in the [Conventions and style guidelines](#conventions-and-style-guidelines) section.

3. Ensure that you log an issue with the details of the problem in the [Documentation Repository Issue Tracker](https://github.com/fabric8io/fabric8-online-docs/issues) for context and assign it to yourself.

4. Clone the documentation repository and make the relevant changes in a branch named after the issue you are working on.

5. Locally build and test the changes. For details on the instructions and tools to do this, see [Locally building the documentation](#locally-building-the-documentation).

6. After the local builds are successful, commit your changes and create a PR for the fixes. In the assignee field, select one of the writers to do a quick review before merging your changes. 

7. For each push to the *master* branch and each PR, a preview build of the documentation is created and available at https://docs.prod-preview.openshift.io/. Build status: [![Build Status](https://ci.centos.org/view/Devtools/job/devtools-fabric8-online-docs-build-master/badge/icon)](https://ci.centos.org/view/Devtools/job/devtools-fabric8-online-docs-build-master/). The creator of the PR and reviewers can use this build for testing, which is why it is essential to test your changes locally before creating the PR.

8. When reviewed, and after any changes necessary are complete, the PR is merged into the documentation.


## Conventions and style guidelines

To get started quickly, we recommend reviewing the following conventions that are relevant for this documentation suite:

### Writing conventions

* For instructions, state the location, then action and subject. For example:
  * **Incorrect:** *Click OK in the XYZ tab to continue.*
  * **Correct:** *In the XYZ tab, click OK to continue.*
* Use gerunds in titles when possible. For example:
  * **Incorrect:** *1.1 Create a new project*
  * **Correct:** *1.1 Creating a new project*
* All titles should be in sentence case. Exceptions for words that are proper nouns. For example:
  * **Incorrect:** *1.2 Configuring Your Che Workspace*
  * **Correct:** *1.2 Configuring your Che workspace*
  
### Markup conventions 

* Use both grave accents and asterisks to mark up system items such as library names, channel and repository names, and user names. For example:
```
Install the `*library_name*` library to continue.
```
* Use underscores for replaceable text within code blocks or inline commands. For example:
```
execute `command _yourConfigFile.txt_`
```
* Use grave accents for inline commands. For example: 
```
Run the `maven build` command in your terminal.
```
* Use the `btn:[Button UI Text]` markup for clickable buttons in the User Interface. For example:

```
Click btn:[Finish] to continue.
```

* Use the `kbd:[button+button]` markup for keyboard shortcuts.
  * Example for single and combination keys: 

  ```
Press kbd:[Ctrl+s] to save your progress and then kbd:[Enter] confirm the changes.
  ```

* For instructions to add a specific string to a field, use grave accents for the string. For example:
```
In the *Name* field, type `spring`.
```

* Names of UI elements are marked up with asterisks. For example: 
```
In the *Plan* tab, view the listed elements.
``` 

* Mark up code snippets with square brackets stating *source* and the language and then the snippet itself with four hyphens at the beginning and end of the code. For example:
  
```
[source,java]
----
  protected static final String template = "Aloha, %s!";
----
```

For comprehensive references for documentation conventions, see the following:

  * The IBM Style Guide. A subset of this guide is available [here](https://www.ibm.com/developerworks/library/styleguidelines/).
  * The [Red Hat Asciidoc Markup conventions](https://redhat-documentation.github.io/asciidoc-markup-conventions/)
  <!-- * The [CCS Documentation Conventions][url here when available] UNCOMMENT THIS WHEN READY but won't be for a while because nobody owns this task-->
  * The [Red Hat modular documentation reference guide](https://redhat-documentation.github.io/modular-docs/#introduction).

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
