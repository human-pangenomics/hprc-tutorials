# HPRC Pangenome Workshop at the Human Genome Meeting (Rome 2024)

This workshop took place in Rome on April, 8 2024 for [Human Genome Meeting (HUGO)](https://www.hugo-hgm2024.org/).
The objective was to teach participants to

- Understand how to leverage pangenomes produced by the HPRC for their work;
- Conduct genomic analyses using diverse pangenome datasets and resources with an intuition about why this improves the validity and utility of their results; and
- Access and analyze pangenomic datasets using high-performance computing (HPC) environments like the commercial AWS cloud executing reproducible workflows.

After some introductions around the project and pangenomes, the participants first **built and analyzed pangenomes with [PGGB](https://github.com/pangenome/pggb)**. 
They witness the effect of different parameters on the constructed pangenome. 
Different pangenomes were also visualized with odgi and analyzed, for example to make a phylogenetic tree of primates, or monitor the growth of the core pangenome as more samples are added.
Participants got familiar with a Nextflow pipeline automating pangenome construction too.
In the second part, [Giraffe](https://github.com/vgteam/vg) was used to **map short sequencing reads to a slice of the HPRC pangenome and small variants were called** using [DeepVariant](https://github.com/google/deepvariant).
Participants first played with a minimal command to align reads to the pangenome and project them to a linear reference genome. 
Hence, they learned how to integrate the HPRC pangenome as a reference for read mapping in their existing pipeline. 
To go further, participants ran the full Giraffe-DeepVariant pipeline with Snakemake, which call SNVs and indels from the aligned reads.
Finally, they investigated the called small variants and visualized their read support on the pangenome.

You can find materials for the workshops below, including:

- slides
- output of the notebooks (viewable on GitHub)
- instructions on how to run the notebook on your machine

Note: for the workshop, we launched a large AWS instance to host the JupyterHub server. We had prepared a Docker image and the large data file (pangenomes and Singularity cache) in advance. See [README.instance_setup.md](README.instance_setup.md) for details on how the image, data, and instances were prepared.

## Slides

- [GoogleSlides link](https://docs.google.com/presentation/d/1HijsejJkJ8x_pEStdOHdVnI-DzNQmhUk9I6MF20Ppsk/edit?usp=sharing)
-  PDF version: [`HUGO-Rome 2024_HPRC-Slides.pdf`](<HUGO-Rome 2024_HPRC-Slides.pdf>).

## Notebooks with output

You can see how the notebooks look like after being run, i.e. with all the log and graphic outputs, in the [`notebooks_with_output` folder](notebooks_with_output).
The notebooks are:

- [hprc_hugo24_pggb.ipynb](hprc_hugo24_pggb.ipynb) on the construction and analysis of pangenomes with PGGB.
- [RHD-RHCE - Small variant calling with Giraffe-DeepVariant.ipynb](<RHD-RHCE - Small variant calling with Giraffe-DeepVariant.ipynb>) about mapping reads with Giraffe and calling small variants with DeepVariant in the RHD-RHCE region.
- [pangenome-sv-genotyping.ipynb](pangenome-sv-genotyping.ipynb) with a simple example of mapping reads with giraffe and genotyping variants.

In that directory, you can also find the HTML reports and other outputs of the nf-core/pangenome Nextflow run in `chrY.hprc.pan4_out`, and other PDF files from the PGGB notebook.

## Run the workshop locally on a local machine

**Note**: we had planned 8 cores and 16 Gb of memory per participant. If your machine has less cores/memory than that, you might need to tweak the commands in the notebook. 
For example, change the `-t 8` to `-t X` where *X* is the number of cores you want to use. 

To run the JupyterHub server on your machine, the easiest is to use one of the Docker images that we've prepared.

### Install Docker

If you don't already have docker on your machine, find out how to install it at [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/).

### Run the JuputerHub container

Two options. 

1. Option 1 if you're planning on running the PGGB part just once or twice, or if you want to play with the Giraffe parts. This is **recommended** in most cases.
1. Option 2 if you're planning on running the PGGB part several times. It takes more time to setup but avoids re-downloading data every time.

#### Option 1: Download the large files within the notebook

Large files are used for the PGGB part.
They can be downloaded using commands (might be commented) in the notebook.

Run this command from the root of this repo (i.e. the directory where this README file is):

```
docker run --privileged -v `pwd`/data:/data:ro -p 80:8000 --name jupyterhub quay.io/jmonlong/hprc-hugo2024-jupyterhub jupyterhub
```

Then, in your browser, navigate to `localhost`. Pick a username, and use the following password: `hugo24pangenome`

Note: there is no Singularity cache either, so the Nextflow or Snakemake workflows will start by downloading them which can take a few minutes.

#### Option 2: Use a Docker image with the large files

If you don't want to download the large files every time, i.e. you want to run the PGGB part several times, you can use an image with the large files included. 
The docker image was deposited on Zenodo at [https://zenodo.org/records/10948633](https://zenodo.org/records/10948633).

To pull the image, either download the TAR file at https://zenodo.org/records/10948633 and run: 

```
docker load -i hprc-hugo2024-jupyterhub-withdata.tar
```

OR

```
curl https://zenodo.org/records/10948633/files/hprc-hugo2024-jupyterhub-withdata.tar | docker load -
```

Once this is done you should have a new docker image called `hprc-hugo2024-jupyterhub-withdata`.
Hence, to start the server, run this command from the root of this repo (i.e. the directory where this README file is):

```
docker run --privileged -v `pwd`/data:/data:ro -p 80:8000 --name jupyterhub hprc-hugo2024-jupyterhub-withdata
```

Then, in your browser, navigate to [localhost](localhost). Pick a username, and use the following password: `hugo24pangenome`

### Launch the sequenceTubeMap server

At the end of the Giraffe part of the workshop, we visualized the pangenomes and mapped reads with the sequenceTubeMap. 
To play with that tubemap, start the server with:

```
docker run -it -p 3210:3000 quay.io/jmonlong/sequencetubemap:vg1.55.0_hugo24
```

Then access it on a web browser at [localhost:3210](localhost:3210).
