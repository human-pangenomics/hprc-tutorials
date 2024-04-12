# Long Read Assembly Workshop

<p align="center">
    <img src="https://github.com/human-pangenomics/hprc-tutorials/blob/GA-workshop/assembly/genomics_aotearoa/images/intro/HG002_bandage.png?raw=true" width="250"/>
</p>

This long read assembly workshop aims to work through an entire assembly workflow including data QC, assembly, and assembly QC.

## We Need More Human Genomes

No single genome can represent the diversity in the human population. Using a single reference genome creates reference biases, adversely affecting variant discovery, gene–disease association studies and the accuracy of genetic analyses.


<p align="center">
    <img src="https://s3-us-west-2.amazonaws.com/human-pangenomics/backup/logo-proof-full.png" width="450"/>
</p>

The [Human Pangenome Reference Consortium](https://humanpangenome.org) (HPRC) is a project funded by the [National Human Genome Research Institute](https://genome.gov) (USA) to sequence and assemble genomes from individuals from diverse populations in order to better represent the genomic landscape of diverse human populations.

## Why Do Good Assemblies Matter?

You can do things with assemblies that you can't with their constituent data. And the better the assembly, the more you can do. For example, the figure below shows a region of the genome with medically relevant loci (Prader Willi) that has regions of long repeats (segmental duplications) that have high sequence similarity. The assemblies on the left use older data and assembly methods can't resolve these loci (see all the gaps), while the assemblies on the right use PacBio HiFi data and Hifiasm with trio phasing to successfully resolve these loci, revealing a likely SV in a region affected by a lack of coverage with older sequencing technology. ([Porubsky _et al._ 2023](https://doi.org/10.1101/gr.277334.122))

<p align="center">
    <img src="https://github.com/human-pangenomics/hprc-tutorials/blob/GA-workshop/assembly/genomics_aotearoa/images/intro/Porubsky_Gaps_Figure1D.png?raw=true" width="450"/>
</p>


In this workshop, we will show you how to make assemblies with PacBio HiFi data, but we will also add in ultra-long Oxford Nanopore reads. The resulting assemblies will just as good as, if not better than, the assemblies shown on the right in the above image.

## Assembly Workflows & Our Approach

The approach we take in this workshop will reflect a normal assembly workflow.

<p align="center">
    <img src="https://github.com/human-pangenomics/hprc-tutorials/blob/GA-workshop/assembly/genomics_aotearoa/images/intro/Assembly_Workflow.svg?raw=true" width="750"/>
</p>

On day one, we will learn about the type of data that goes into current assemblers. On day two, we will use two of the most popular and powerful assemblers currently available. And on day three, we will take a look at the assemblies to assess their quality and see what we can do with them.
