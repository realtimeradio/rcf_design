# DSA-2000 RCF Design#

This repository holds documents that describe the DSA2000 RCF Subsystem.


## Instructions for generating PDF version of documentation

For those wanting to generate a PDF locally

### Requirements

To build the documents locally you will require a local `pandoc` and `latex` install with appropriate style files.

On `Ubuntu 22.04` this can be achieved with:

``` shell
apt install texlive-latex-recommended texlive-latex-extra pandoc
```

Example build commands:

Interactive version of the document:

``` shell
pandoc docs/*.md -o rcf_design.pdf -s -V colorlinks --template template.latex
```

Printable version of the document:

``` shell
pandoc docs/*.md -o rcf_design.pdf -s -V colorlinks -V links-as-notes --number-sections --template template.latex
```
