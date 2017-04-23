# Documentation for Red Hat SaaS Offering for Developers

This is the Git repository for documentation related to Red Hat developer SaaS.


## Repository Structure


The repository contains several "books", each of which is in its own directory. All book directories use the same layout.


### Book Directories

Books are organized into folders. Each book's folder contains:

- `_common_content_` -- symlink to shared-content directory
- **content/** -- for content (`.adoc` files)
- `files/` -- for downloadable files
- `images/` -- for images
- **docinfo.xml** -- Docbook definitions for Pantheon
- **master.adoc** -- book root

Items in **bold** are mandatory, and the rest is optional.


## Building the Documentation

To build a book, `cd` into its directory and compile its `master.adoc` using either `asciidoctor` (for quick local previews) or `ccutil` (to see how the book builds and renders with Red hat branding).


### Using AsciiDoctor

```
$ cd <guide-directory>
$ asciidoctor --section-numbers --attribute=toc master.adoc
$ <www-browser-of-choice> master.html
```

Substitute `<www-browser-of-choice>` for whatever web browser you use.


### Using ccutil

```
$ cd <guide-directory>
$ ccutil compile --lang en-US --open
```

This will automatically open the compiled guide in the default web browser.


## Bug Tracking

Bugs and RFEs for Red Hat developer SaaS docs are tracked in the RHDEVDOCS project in the JBoss instance of JIRA at [https://issues.jboss.org/browse/RHDEVDOCS](https://issues.jboss.org/browse/RHDEVDOCS).
