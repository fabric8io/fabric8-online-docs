
# Documentation for Red Hat OpenShift.io

This is the Git repository for documentation related to Red Hat OpenShift.io, the SaaS for developers. The documentation is available at http://docs.openshift.io.


Additionally, a preview build of the *master* branch of this repository is available at https://docs.prod-preview.openshift.io/. Build status: [![Build Status](https://ci.centos.org/view/Devtools/job/devtools-fabric8-online-docs-build-master/badge/icon)](https://ci.centos.org/view/Devtools/job/devtools-fabric8-online-docs-build-master/).

## Repository structure

Briefly, this is what you need to know about the documentation repository structure before contributing:

* The documentation is module-based, which means most sections are individual modules. These modules are available in the `/docs/topics/modules/` folder.
* The modules are linked together to form a chapter, document, or guide using assemblies. These assemblies are asciidoc files in the `/docs/topics/` folder. For example, the `/docs/topics/getting-started-guide.adoc` file is the main assembly for the Getting Started Guide and links to other, smaller assemblies for parts or chapters within the guide.
* Module files naming conventions closely follow the title of the corresponding section. For example, a section in the Getting Started document with the title *Working with pipelines* is named `working_with_pipelines.adoc` in the `modules` folder. In some cases, this is not a direct match, so to confirm the name of the asciidoc file for a section, click the section title and the ID after the *#* in the URL is the name of the module file. For example, a URL such as https://docs.openshift.io/getting-started-guide.html#viewing_build_pipeline_oso has a slightly different title but the ID after the hash symbol (`viewing_build_pipeline_oso`) is the name of the file.

## Contributing to the docs

See the [Contributor guidelines](./CONTRIBUTING.md) for instructions.