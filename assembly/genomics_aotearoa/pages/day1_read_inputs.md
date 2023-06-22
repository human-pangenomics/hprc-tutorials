# PacBio & ONT Data
## PacBio Hifi: Illumina-Like Quality With Long Reads
**What is PacBio HiFi**
Pacbio's high fidelity (or HiFi) reads are long (~15kb) and accurate (~99.9%). PacBio produces such high quality reads (with their single-molecule real-time, or SMRT, sequencing) by reading the same sequence over and over again in order to create a circular consensus sequence (or CCS) as shown below. 

**PacBio's CCS Process**
![PacBio CCS Process](https://raw.githubusercontent.com/human-pangenomics/hprc-tutorials/GA-workshop/assembly/genomics_aotearoa/images/sequencing/HiFi-reads-img.svg)

Long, highly accurate reads allows for a number of analyses that were difficult or impossible in the context of short reads. For instance, variants can be more easily phased as you can just look for variants that are seen in the same sequencing read. In our context, long accurate reads allow assembly algorithms to build assembly graphs across difficult regions. But it turns out that HiFi reads aren't long enough to span exact repeats in regions like human centromeres.

## ONT Ultralong: Lower Quality But Really Long Reads
Oxford Nanopore's ultralong (UL) sequencing has lower accuracy (~90%), but is really long (even longer than normal ONT). This is achieved though a different library prep -- as compared to normal DNA sequencing with ONT. UL library prep uses a transposase to cut DNA at non specific sites where it can then be adapted for sequencing. 

**ONT Ultralong Library Prep**
![ONT UL Library Process](https://raw.githubusercontent.com/human-pangenomics/hprc-tutorials/GA-workshop/assembly/genomics_aotearoa/images/sequencing/ULK114_workflow_V1-3.svg)

The time, transposase amount, and temperature are all factors that effect transposase activity. The more you cut, the shorter the reads. ONT's standard DNA library prep, on the other hand, shears DNA then ligates adapters. (If you've created DNA libraries using Illumina's TruSeq kits, then you get the idea.)

These UL reads, while less accurate than HiFi, span tricky regions making UL and HiFi data highly complementary, especially in the context of denovo assembly, as we will see.

## Familiarize Ourselves With The Data
Let's get our hands on some data so we can see with our own eyes what HiFi and UL data look like.

**Create A Directory**
```
mkdir day1_data
cd day1_data
```
**Subset Our Input Data**<br>
In order to get a feel for the data we only need a small portion of it. Pull the first few thousand reads and write them to new files.
```
zcat /nesi/nobackup/nesi02659/LRA/resources/LRA_hifi.fq.gz \
    | head -n 200000 \
    | pigz > LRA_hifi_50k_reads.fq.gz &

zcat /nesi/nobackup/nesi02659/LRA/resources/LRA_ONTUL.fq.gz \
    | head -n 4000 \
    | pigz > LRA_ONTUL_1k_reads.fq.gz &
```

**Now let's compare the data**<br>
We are going to use a tool called NanoComp. This tool can take in multiple fastqs (or bams) and will create summary statistics and nice plots that show things like read length and quality scores. NanoComp has nano in the name, and has some ONT-specific functionality, but it can be used with PacBio data just fine.
```
NanoComp --fastq \
    LRA_hifi_50k_reads.fq.gz \
    LRA_ONTUL_5k_reads.fq.gz \
    --names PacBio_HiFi ONT_UL \
    --outdir nanocomp_hifi_vs_ul
```
Once the run is complete, navigate in your file browser to the NanoComp-report.html file and click on it to open it. Take a look at the plots for log-transformed read lengths and basecall quality scores. 

<details>
    <summary>
        <strong>What do you expect each datatype to be used for in assembly?</strong>
    </summary>
    Answer
</details>

# Cleaning Data For Assembly
## PacBio Adapter Trimming
PacBio's CCS software attempts to identify adapters and remove them. This process is getting better all the time, but some older datasets can have adapters remaining. If this is the case adapters can 
```
cutadapt \
    -b "AAAAAAAAAAAAAAAAAATTAACGGAGGAGGAGGA;min_overlap=35" \
    -b "ATCTCTCTCTTTTCCTCCTCCTCCGTTGTTGTTGTTGAGAGAGAT;min_overlap=45" \
    --discard-trimmed \
    -o /dev/null \
    LRA_hifi_50k_reads.fq.gz \
    -j 0 \
    --revcomp \
    -e 0.05
```
Notice that we are writing to `/dev/null`. We are working on a subset of these reads so the runtime is reasonable. So there is no reason to hold onto the reads that we are filtering.

<details>
    <summary>
        <strong>What do you think these two sequences are? (hint: you can Google them)</strong>
    </summary>
    Answer
</details>

<details>
    <summary>
        <strong>Why can we get away with throwing away entire reads that contain adapter sequences?</strong>
    </summary>
    Answer
</details>

<details>
    <summary>
        <strong>What would happen if we left adapter sequences in the reads?</strong>
    </summary>
    Answer
</details>


## ONT Read Length Filtering
Hifiasm is often run with ONT data filtered to be over 50kb in length. 
```
seqkit seq \
    -m 50000 \
    LRA_ONTUL_1k_reads.fq.gz \
    | pigz > LRA_ONTUL_1k_reads.50kb.fq.gz &
```
<details>
    <summary>
        <strong>Why do you think an assembler might want to include only reads over 50kb?</strong>
    </summary>
    Answer
</details>
