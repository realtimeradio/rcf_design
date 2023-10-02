#! /bin/bash

pandoc docs/*.md -o rcf_design.pdf -s -V colorlinks -V links-as-notes --number-sections --template template.latex
