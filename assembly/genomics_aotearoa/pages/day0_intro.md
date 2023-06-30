# Long Read Assembly Workshop

<p align="center">
    <img src="https://github.com/human-pangenomics/hprc-tutorials/blob/GA-workshop/assembly/genomics_aotearoa/images/intro/PAN027_bandage.png?raw=true" width="250"/>
</p>

This long read assembly workshop aims to work through an entire assembly workflow including data QC, assembly, and assembly QC.

## We Need More Human Genomes

No single genome can represent the diversity in the human population. Using a single reference genome creates reference biases, adversely affecting variant discovery, gene–disease association studies and the accuracy of genetic analyses.


<p align="center">
    <img src="https://s3-us-west-2.amazonaws.com/human-pangenomics/backup/logo-proof-full.png" width="450"/>
</p>

The Human Pangenome Reference Consortium (HPRC) is a project funded by the National Human Genome Research Instititue to sequence and assemble genomes from individuals from diverse populations in order to better represent genomic landscape of diverse human populations.

## Why Do Good Assemblies Matter?

You can do things with assemblies that you can't with their constituant data. And the better the assembly, the more you can do. For example the figure below shows a region of the genome with medically relevant loci (Prader Willi) that has regions of long repeats (segmental duplications) that have high sequence similarity. The assemblies on the left which use older data and assembly methods can't resolve these loci while the assemblies on the right which use PacBio HiFi data and Hifiasm with trio phasing can.

<p align="center">
    <img src="https://github.com/human-pangenomics/hprc-tutorials/blob/GA-workshop/assembly/genomics_aotearoa/images/intro/Porubsky_Gaps_Figure1D.png?raw=true" width="450"/>
</p>


In this workshop we will show you how to make assemblies with PacBio hifi data, but we will add in ultralong oxford nanopore reads. The resultant assemblies will just as good if not better than the assemblies shown on the right.

## Assembly Workflows & Our Approach

The approach we take in this workshop will reflect a normal assembly workflow.

<p align="center">
    <img src="https://github.com/human-pangenomics/hprc-tutorials/blob/GA-workshop/assembly/genomics_aotearoa/images/intro/Assembly_Workflow.svg?raw=true" width="750"/>
</p>

On day one we will learn about the type of data that goes into current assemblers. On day two we will use two of the most popular and powerful assemblers out right now. And on day three we will take a look at the assemblies to see how good they are and what we can do with them.