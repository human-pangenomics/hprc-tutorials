# Demo JupyterHub Docker image
#
# This should only be used for demo or testing and not as a base image to build on.
#
# It includes the notebook package and it uses the DummyAuthenticator and the SimpleLocalProcessSpawner.
FROM quay.io/jupyterhub/jupyterhub-onbuild:main

# general ubuntu deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    graphviz \
    wget \
    gcc \
    build-essential \
    g++ \
    git \
    jq \
    python3-dev \
    tzdata \
    r-base r-base-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    apt-transport-https \
    software-properties-common \
    dirmngr \
    gpg-agent \
    libncurses5-dev \
    libncursesw5-dev \
    libfontconfig1-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libfuse2 \
    crun \
    runc \
    cryptsetup-bin \
    fuse \
    fuse2fs \
    uidmap \
    squashfs-tools \
    default-jre \
    bedtools \
    autoconf \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# time zone
RUN export TZ=Europe/Paris && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# conda
WORKDIR /build

RUN wget --no-check-certificate --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda

ENV PATH /miniconda/bin:${PATH}

# for binaries
ENV PATH /bin:$PATH

# vg
WORKDIR /bin

RUN wget --quiet https://github.com/vgteam/vg/releases/download/v1.54.0/vg && \
    chmod +x vg

## nextflow
WORKDIR /build/nextflow

ENV NXF_HOME=/build/nextflow

RUN curl -s https://get.nextflow.io | bash && \
    chmod +r /build/nextflow/framework/23.10.1/nextflow-23.10.1-one.jar && \
    chmod +xr nextflow && \
    mv nextflow /bin/ 

# PGGB
RUN conda install -y -c conda-forge bc && conda install -y -c bioconda pggb==0.5.4 python=3.9

# pafplot
WORKDIR /build/cargo

ENV CARGO_HOME=/build/cargo

ENV RUSTUP_HOME=/build/cargo

RUN wget -O rust-init.sh https://sh.rustup.rs && \
    sh rust-init.sh -y

ENV PATH=/build/cargo/bin:${PATH}

RUN git clone https://github.com/ekg/pafplot && \
    cd pafplot && \
    cargo install --force --path . && \
    mv target/release/pafplot /bin/pafplot

# samtools
RUN wget --quiet --no-check-certificate https://github.com/samtools/samtools/releases/download/1.19.2/samtools-1.19.2.tar.bz2 && \
    tar -xjvf samtools-1.19.2.tar.bz2 && \
    cd samtools-1.19.2 && \
    autoheader && \
    autoconf -Wno-syntax && \
    ./configure && \
    make && \
    make install

# R packages
ADD install.R /build

RUN R -f /build/install.R

## panacus
WORKDIR /build

RUN wget --quiet --no-check-certificate -c https://github.com/marschall-lab/panacus/releases/download/0.2.3/panacus-0.2.3_linux_x86_64.tar.gz && \
    tar -xzvf panacus-0.2.3_linux_x86_64.tar.gz && \
    mv panacus-0.2.3_linux_x86_64/bin/panacus /bin && \
    mv panacus-0.2.3_linux_x86_64/scripts/panacus-visualize.py /bin/panacus-visualize && \
    chmod +rx /bin/panacus-visualize

# singularity
WORKDIR /build

RUN wget -q https://github.com/sylabs/singularity/releases/download/v4.1.2/singularity-ce_4.1.2-focal_amd64.deb && \
    apt install ./singularity-ce_4.1.2-focal_amd64.deb && \
    rm singularity-ce_4.1.2-focal_amd64.deb

# maybe this helps for "loop device" limit
RUN sed -i -e 's/shared loop devices = no/shared loop devices = yes/' /etc/singularity/singularity.conf

# # I thought this would help even more for the "loop device" issue but it made it worse
# RUN sed -i -e 's/shared loop devices = no/shared loop devices = yes/' /etc/singularity/singularity.conf && \
#     sed -i -e 's/max loop devices = 256/max loop devices = 8/' /etc/singularity/singularity.conf

# snakemake, notebook and other python modules
RUN python3 -m pip install datrie pulp==2.7.0 pandas scipy seaborn scikit-learn

RUN python3 -m pip install notebook snakemake cyvcf2

# RUN conda install -c conda-forge jupyter jupyterhub

# Create a demo user
WORKDIR /srv/jupyterhub

RUN useradd --create-home demo
RUN chown demo .

USER demo
