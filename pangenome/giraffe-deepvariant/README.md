# Short Read Variant Calling With Giraffe & DeepVariant
The tutorial demonstrates variant calling using the Human Pangenome Reference Consortium's (HPRC) year 1 Minigraph/CACTUS pangenome with the Giraffe/DeepVariant pipeline for calling germline small variants. This tutorial uses a "public" workspace in AnVIL and is intended to be a demonstration of utilizing a pangenome from the HPRC in AnVIL and Terra. In order to follow along with the tutorial you will have to sign up for Terra (see the instructions). Instructions for this tutorial can be found in the `instructions/` folder.

Note that the WDL included in the workspace is still under active development. For up-to-date best practices for both Giraffe and DeepVariant please see the links included in the relevant sections below.

## Tasks

1. Clone workspace
2. Have a look at the "sample" Table, the "Workspace Data", and the "Files"
3. Launch a workflow on the sample in the "sample" Table.
4. Monitor running job
5. Notebook
   1. Launch an Analyses jupyter notebook
   2. Once the workflow job is done (steps 3-4 above), start running code in the notebook.
	 3. (Optional) Discuss pangenome (+reads) representations. What's going on?
	 4. (Optional) Blast a read to GRCh38. Why would GRCh38 lead to false-negative in this region?

Side tasks:

1. Find the GiraffeDeepVariant workflow in dockstore
2. Find data in AnVIL, e.g. 1000GP reads, HPRC assemblies/pangenomes

Detailed instructions for running this workspace can be downloaded from [here](https://docs.google.com/document/d/1BmVYP8UvQX5mRztu37kZac0BP_aOAnocL2X5caGMQvQ/edit?usp=sharing).

## Data

For this demonstration, we will work with a region of chromosome 1 containing, among others, the RHCE gene which is a a challenging medically-relevant gene. "Challenging medically-relevant genes" are difficult to assess with short-read sequencing but are part of a recent benchmark truthset ([CRMG v1.0](https://www.nature.com/articles/s41587-021-01158-1)). The genomic interval extracted was `chr1:25053647-25685365` ([see in the UCSC Genome Browser](https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&position=chr1%3A25053647%2D25685365)). 
The reads and pangenome in this workspace correspond to this slice of the genome.

### HG002 Illumina Reads (30X)

The sample-based data we will use in this workspace is loaded into the sample data table. An Illumina dataset (produced by Google and made publicly available) with 30X coverage of HG002 has been sliced on the relevant region (as explained above) and imported into the workspace. The sample table has multiple columns and the columns with the prefix input_ (e.g. input_fastq_1) are used as inputs for the Giraffe/DeepVariant workflow. The workflow has been prerun in a separate table "sample_prerun" for convenience, and the outputs have been written to columns with names prepended with "output_".

### Minigraph/CACTUS Pangenome

This workspace uses one of the HPRC's year 1 pangenomes created with the [Minigraph/CACTUS pipeline](https://github.com/ComparativeGenomicsToolkit/cactus/blob/master/doc/pangenome.md). For the Giraffe/DeepVariant pipeline, it is recommended to use a filtered version of the GRCh38-based graph. Information about the HPRC's pangenome releases can be found in the HPRC's [publicly available AnVIL workspace](https://app.terra.bio/#workspaces/anvil-datastorage/AnVIL_HPRC) as well as the HPRC's [pangenome resources GitHub repo](https://github.com/human-pangenomics/hpp_pangenome_resources).

For this demonstration, we extracted the sub-graph of the chr1 region from the non-filtered GRCH38-based pangenome, in order to deal with only one pangenome for both variant calling and visualization of all the haplotypes.

### DeepVariant (DV) Model

DeepVariant uses a learned model to call variants in aligned sequencing data. A model has been imported into this workspace and can be found in the Data tab under ```Files --> dv-giraffe-model/.```. The model was trained with DV 1.3 on the GRCh38-based Cactus-Minigraph pangenome, on ~30-40x coverage read sets.

## Workflow: Variant Calling With a Pangenome & Giraffe/DeepVariant


### [GiraffeDeepVariant](https://dockstore.org/workflows/github.com/vgteam/vg_wdl/GiraffeDeepVariantLite:giraffe-dv-dt-hprcy1)

This workflow aligns reads to a pangenome graph and uses Google's DeepVariant caller to produce an output VCF. The steps are summarized below:

1. Split reads
2. Align reads to pangenome with Giraffe
3. Realign around InDels (optional)
4. Call variants with DeepVariant


#### Recommended Inputs

**This workflow has a number of inputs. For convenience the recommended workflow inputs have been pre-populated in the workflow inputs tab. Alternatively, users may navigate to the [example input json](https://drive.google.com/file/d/1zYfiUPYS8ZaWnWhaHMNnGCYfu5XRHlZj/view?usp=sharing) and [example output json](https://drive.google.com/file/d/1gaDxfT2u0U5avmpGet_KdJhD9M4ex6bX/view?usp=sharing) included as part of this workspace.**


#### Outputs

* output_vcf: VCF output from DeepVariant
* output_calling_gam: reads aligned to the pangenome with Giraffe as a GAM file.

#### Time and cost estimates    
Note that actual time and cost may vary due to the use of preemptible instances. 

| Input Coverage | Time | Cost |
| -------- | -------- | ---------- |
| 30X | < 5 minutes | $1 |

*(for the subset data included in this workspace)*

## Notebook: Visualize pangenome and reads around a called variant

The notebook can be found in the *ANALYSES* tab.

The "Environment configuration" to run it should be:

- *Jupyter* environment
	- Custom environment
		- *Application configuration*: *Custom environment*
		- *Container image*:  `jmonlong/terra-notebook-vg:1.1` 

### Alternative: interactive visualization with the SequenceTubeMap

The approach showed in the notebook can be useful to look at a small subgraph or automate image creation. 
For other use cases, we tend to use the interactive (and better-looking) [SequenceTubeMap](https://github.com/vgteam/sequenceTubeMap). 
Below is what the notebook example would look like:

![](http://public.gi.ucsc.edu/~jmonlong/hprc/ashg2022-hprc-workshop-tubemap-example.small.png)


## Next Steps
To run this pipeline on your own data you have to upload your data to the Google Cloud bucket for your version of the workspace. You can find the bucket information in the Google Bucket section on the right hand side of this page. In that section you can find the bucket name for gsutil commands, or you can open the bucket in your web browser. You can also (optionally) create a new data table in your workspace which points to the data you uploaded.

----
----
## Authors and contact information

This workspace is a product of the Human Pangenome Reference Consortium [HPRC](https://humanpangenome.org/) and [the AnVIL](https://anvilproject.org/). Contributors include:

* Jean Monlong: jmonlong@ucsc.edu (UCSC Computational Genomics Lab)
* Julian Lucas: juklucas@ucsc.edu (UCSC Computational Genomics Platform)

The Giraffe/DeepVariant workflow was developed by the VG team at UCSC and Google. Contributors include:

* Charles Markello (UCSC)
* Jean Monlong (UCSC)
* Adam Novak (UCSC)
* Maria Nattestad (Google)
* Pichuan Chang (Google)
* Andrew Carroll (Google)

## Additional generally helpful resources

* **[HPRC Pangenome GitHub](https://github.com/human-pangenomics/hpp_pangenome_resources)**   
    Description of HRPC's currently available (release) pangenomes.   
		 
		
* **For helpful hints on controlling cloud costs**, see [this article (https://support.terra.bio/hc/en-
us/articles/360029748111)](https://support.terra.bio/hc/en-us/articles/360029748111).      
 

 ## Citations
 
1. Sirén, Jouni, et al. "Pangenomics enables genotyping of known structural variants in 5202 diverse genomes." Science 374.6574 (2021): abg8871.
2. Poplin, Ryan, et al. "A universal SNP and small-indel variant caller using deep neural networks." Nature biotechnology 36.10 (2018): 983-987.