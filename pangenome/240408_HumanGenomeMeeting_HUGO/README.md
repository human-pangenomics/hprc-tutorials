Notes to prepare or use the JupyterHub server for the HPRC Pangenome workshop at HUGO 2024.

To find out how to **run it locally on your computer** see [README.local.md](README.local.md).

To see what the **notebooks with the outputs/plots**, go to the [`notebooks_with_output` folder](notebooks_with_output).

# Launch a prepared instance

## Launch on EC2

- Start from an image
    - in left panel: *Images* -> *AMIs* 
    - select latest image, e.g. *hprc-workshop-hugo-2024*
    - *Launch instance from AMI*
- Ubuntu Server 22.04, for example:
    - t2.micro for testing
    - c5.9xlarge for testing with a few users
    - u-6tb1.112xlarge for the workshop
- Pick enough disk space, for example 5 Tb (100Gb * 50 participants).
- pick your personal keypair
- Allow HTTPS and HTTP traffic from the internet

## Save the IP

Once the instance is running, save the instance's public IP locally as an ENV variable

```
IP=34.215.133.12
```

## Connect to instance 

Using your keypair:

```
ssh -i ~/.ssh/jmonlong-hprc-training.pem ubuntu@$IP
```

## Optional: update data

When starting from an image, the instance should have all the necessary data.

If they have changed, or when starting an instance from scratch:

- [Download/update the data](#downloadupdate-the-data)
- [Download/update the notebooks](#downloadupdate-the-notebooks)
- [Import Docker image with big files](#Import-Docker-image-with-big-files)

## Launch JupyterHub from a screen

```
screen -S hub

docker run --privileged -v `pwd`/data:/data:ro -v `pwd`/singularity_cache:/singularity_cache:ro -p 80:8000 --name jupyterhub jh jupyterhub
```

The JupyterHub should be accessible at the public IP through HTTP (https://<IP> won't work!).
The password is `hugo24pangenome`

Note: see *Issues* below if docker doesn't start.

To restart the JupyterHub:

```
docker rm jupyterhub
```

# Prepare the Docker image

```
docker build -t jmonlong-jupyterhub .

## test locally
docker run --privileged -v `pwd`/data:/data:ro -v `pwd`/bigdata:/bigdata:ro -v `pwd`/singularity_cache:/singularity_cache:ro -p 80:8000 --name jupyterhub jmonlong-jupyterhub jupyterhub
docker rm jupyterhub

## push to quay.io
docker tag jmonlong-jupyterhub quay.io/jmonlong/hprc-hugo2024-jupyterhub
docker push quay.io/jmonlong/hprc-hugo2024-jupyterhub
```

## Prepare Docker image containing the big files

When a directory is mounted/bound in the docker command, if behaves like a separate disk. 
Hence, accessing/moving large files can be very slow. 
The PGGB part uses files that are several Gbs so we instead include them in the Docker image.
This is not great practice so to avoid uploading this extra large image to a public repository, we save it as a TAR file.
This TAR file can be saved like a typical large file, e.g. in S3, and downloaded and imported when needed.

```
docker build -f workshop-hprc-hugo24/Dockerfile_withdata -t hprc-hugo2024-jupyterhub-withdata .
docker save -o hprc-hugo2024-jupyterhub-withdata.tar hprc-hugo2024-jupyterhub-withdata
aws s3 cp hprc-hugo2024-jupyterhub-withdata.tar s3://hprc-training/hugo24/
```

### Upload the large image to Zenodo

I created a Zenodo draft upload and uploaded the TAR file using https://github.com/jhpoelen/zenodo-upload

# Prepare an instance from scratch

## Minimal installation

```
## install docker, maybe not the best way but works
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable"
sudo apt update
sudo apt install -y docker-ce
sudo usermod -aG docker ${USER}
sudo su - ${USER}

## install screen and AWS CLI
sudo apt install -y awscli screen
```

## Download/update the data

To download the files from S3, I couldn't find a better way than copying my local credentials to the instance...

```
mkdir -p ~/.aws
## locally: scp -i ~/.ssh/jmonlong-hprc-training.pem ~/.aws/config ~/.aws/credentials ubuntu@$IP:.aws/
```

Then

```
aws s3 sync s3://hprc-training/hugo24/ .
```

**Don't forget to remove your AWS credentials after that!**

```
rm ~/.aws/config ~/.aws/credentials
```

## Download/update the notebooks

To update just the notebooks, assuming the big data or cached Singularity images have not changed, we can just pull the latest version of this repo.

```
git clone https://github.com/jmonlong/workshop-hprc-hugo24.git
rm -rf data
cp -r workshop-hprc-hugo24/data .
```

## Import Docker image with big files

```
docker load -i hprc-hugo2024-jupyterhub-withdata.tar
```

The tar file should be available after the "sync" command from above. 
Otherwise, to download that file specifically:

```
aws s3 cp s3://hprc-training/hugo24/hprc-hugo2024-jupyterhub-withdata.tar .
```

# Prepare the large public files

The `bigdata` directory contains public data used in the PGGB part and can be prepared with `download-bigdata.sh`.
Some files are >5Gb so it saves time to download them in advance once instead of having every participant do, all at the same time.

This directory was saved in `s3://hprc-training/hugo24/`.

```
aws s3 sync bigdata s3://hprc-training/hugo24/bigdata --dryrun
```

# Prepare the Singularity cache

We can download the singularity images in advanced. It avoids having all the participants downloading them all at once. We save the "cache" in a `singularity_cache` directory.

To fill the cache, we can run each pipeline once using the prepared container.

Start the container

```
docker run -it --privileged -u `id -u $USER` -v `pwd`/bigdata:/bigdata -v `pwd`/data:/data -v `pwd`/singularity_cache:/singularity_cache quay.io/jmonlong/hprc-hugo2024-jupyterhub /bin/bash
```

Within that container:

```
cd /data/giraffe-deepvariant-rhce/
git clone -b hapsampdv https://github.com/vgteam/vg_snakemake.git
snakemake --singularity-prefix /singularity_cache --use-singularity --snakefile vg_snakemake/workflow/Snakefile --configfile smk.config.rhce.yaml --cores 2 all -n

cd /data/pggb
NXF_HOME=/data/pggb NXF_SINGULARITY_CACHEDIR=/singularity_cache nextflow run nf-core/pangenome -r 1.1.2 --input /bigdata/chrY.hprc.pan4.fa.gz --outdir chrY.hprc.pan4_out --n_haplotypes 4 --wfmash_map_pct_id 98 --wfmash_segment_length 10k --wfmash_n_mappings 3 --seqwish_min_match_length 311 --smoothxg_poa_length \"1000,\" -c hprc_hugo24.config,chrY.hprc.pan4.config --wfmash_exclude_delim '#' -profile singularity --wfmash_chunks 4

```

Exit the container and sync the S3 bucket

```
aws s3 sync singularity_cache s3://hprc-training/hugo24/singularity_cache --dryrun
```

Eventually, clean up:

```
rm -rf data/giraffe-deepvariant-rhce/vg_snakemake  data/giraffe-deepvariant-rhce/results /data/pggb/chrY.hprc.pan4_out /data/pggb/work /data/pggb/secrets /data/pggb/assets /data/pggb/capsule /data/pggb/framework /data/pggb/plugins /data/pggb/tmp
```

# Issues

### Docker problem: `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`

Docker sometimes bug. One way to fix is to quickly reinstalling it:

```
sudo apt install -y docker-ce
```

# Monitor usage on a big instance

A few tricks to keep watch:

- Change htop's config to show the total CPU used instead of each CPU's usage
    - Edit `~/.config/htop/htoprc`
    - Replace `left_meters=AllCPUs Memory Swap` by ``left_meters=CPU Memory Swap` for example
- Connect to the JupyterHub using the admin username and go to `http://<IP>/hub/admin` to manage users.

# Prepare the sequenceTubeMap server

## Docker image 

```
## clone repo
git clone https://github.com/vgteam/sequenceTubeMap.git
## copy data files
cp tubemap/*gbz tubemap/*gam tubemap/*gai tubemap/*xg sequenceTubeMap/exampleData/internal/
## copy config file
cp tubemap/config.json sequenceTubeMap/docker/
## move to the docker folder to build the image
cd sequenceTubeMap/docker
## optional. update the vg version used in Docker file
## build image
docker build -t sequencetubemap -f Dockerfile ..
docker tag sequencetubemap quay.io/jmonlong/sequencetubemap:vg1.55.0_hugo24
docker push quay.io/jmonlong/sequencetubemap:vg1.55.0_hugo24
```

## Option 1: on an instance

Launch an instance with docker installed. 
For example, the same image that was prepared for the JupyterHub server.
Then: 

```
screen -S tubemap
docker run -it -p 80:3000 quay.io/jmonlong/sequencetubemap:vg1.55.0_hugo24
```

Access through the public IP (if HTTP access was enabled when launching it).

## Option 2: on Courtyard

This sequenceTubeMap and the small pangenomes used in the workshop won't use much ressources. 
We could serve it on Courtyard (UCSC machine with public access).

```
screen -S tubemap
docker run -it -p 2024:3000 quay.io/jmonlong/sequencetubemap:vg1.55.0_hugo24
```

Then access at http://courtyard.gi.ucsc.edu:2024
