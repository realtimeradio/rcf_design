#! /bin/bash
pdfname=D2k-00016-RCF-DES-Preliminary_Design.pdf

pandoc docs/*.md -o ${pdfname} -s -V colorlinks -V links-as-notes --number-sections --template template-pd2.9.latex --bibliography bibliography.bib
