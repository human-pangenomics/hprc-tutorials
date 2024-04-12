# Notebooks with output

You can find the notebooks with the outputs/plots in the [`notebooks_with_output` folder](notebooks_with_output).

# Run the workshop locally on a local machine

**Note**: we had planned 8 cores and 16 Gb of memory per participant. If your machine has less cores/memory than that, you might need to tweak the commands in the notebook. 
For example, change the `-t 8` to `-t X` where *X* is the number of cores you want to use. 

To run the JupyterHub server on your machine, the easiest is to use one of the Docker images that we've prepared.

## Install Docker

If you don't already have docker on your machine, find out how to install it at [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/).

## Run the JuputerHub container

Two options. 

1. Option 1 if you're planning on running the PGGB part just once or twice, or if you want to play with the Giraffe parts. This is **recommended** in most cases.
1. Option 2 if you're planning on running the PGGB part several times. It takes more time to setup but avoids re-downloading data every time.

## Option 1: Download the large files within the notebook

Large files are used for the PGGB part.
They can be downloaded using commands (might be commented) in the notebook.

Run this command from the root of this repo (i.e. the directory where this README file is):

```
docker run --privileged -v `pwd`/data:/data:ro -p 80:8000 --name jupyterhub quay.io/jmonlong/hprc-hugo2024-jupyterhub jupyterhub
```

Then, in your browser, navigate to `localhost`. Pick a username, and use the following password: `hugo24pangenome`

Note: there is no Singularity cache either, so the Nextflow or Snakemake workflows will start by downloading them which can take a few minutes.

## Option 2: Use a Docker image with the large files

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

# Launch the sequenceTubeMap server

At the end of the Giraffe part of the workshop, we visualized the pangenomes and mapped reads with the sequenceTubeMap. 
To play with that tubemap, start the server with:

```
docker run -it -p 3210:3000 quay.io/jmonlong/sequencetubemap:vg1.55.0_hugo24
```

and access it on a web browser at [localhost:3210](localhost:3210).
