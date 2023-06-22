# PacBio & ONT Data
## PacBio Hifi: Illumina-Like Quality With Long Reads
**Figure showing CCS process**
## ONT Ultralong: Lower Quality But Ultra-Long Reads
Figure showing ONT process

## Familiarize Ourselves With The Data
**Let's Create A Directory**
```
mkdir day1_data
cd day1_data
```
**Subset Our Input Data**<br>
We'd like to get a feel for our data. In order to do so we only need a small portion of it. Pull the first few thousand reads and write them to new files.
```
zcat /nesi/nobackup/nesi02659/LRA/resources/LRA_hifi.fq.gz \
    | head -n 200000 \
    | pigz > LRA_hifi_50k_reads.fq.gz &

zcat /nesi/nobackup/nesi02659/LRA/resources/LRA_ONTUL.fq.gz \
    | head -n 4000 \
    | pigz > LRA_ONTUL_1k_reads.fq.gz &
```

**Now let's compare the data**<br>
We are going to use a tool called NanoComp. It has nano in the name, and has some ONT-specific functionality, but it can be used with PacBio data just fine.
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
    LRA_hifi_5k_reads.fq.gz \
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
    LRA_ONTUL_5k_reads.fq.gz \
    | pigz > LRA_ONTUL_5k_reads.50kb.fq.gz &
```
<details>
    <summary>
        <strong>Why do you think an assembler might want to include only reads over 50kb?</strong>
    </summary>
    Answer
</details>
