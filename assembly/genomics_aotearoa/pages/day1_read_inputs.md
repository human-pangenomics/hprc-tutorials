# Preamble: What Data Are We Using?

**Genome In A Bottle & HG002** 

In this workshop we will be using data from HG002 which is a reference sample from the [Genome In A Bottle (GIAB)](https://www.nist.gov/programs-projects/genome-bottle) consortium. If you aren't familiar, the GIAB project releases benchmark data for genomic characterization. You may have seen their high confidence variant calls and regions out in the wild. As part of their benchmarking material generation they release datasets for their reference samples. We will be using those in this workshop.

**Family Structure**

HG002 is actually part of a trio of reference samples. Below is the family listing:
* HG002: Son
* HG003: Father
* HG004: Mother

If you'd like to use data from any of the Ashkenazim trio, there is a set of [index files on the GIAB github](https://github.com/genome-in-a-bottle/giab_data_indexes).

**There is an excellent HG002 assembly available**

Since HG002 has so much data to compare against, it is pretty common for new technologies to benchmark on HG002 -- making even more HG002 data. It has grown into a data ecosystem. This is part of the reason that it was chosen the the T2T consortium as the target for one of it's next big pushes: a [high-quality diploid T2T genome](https://github.com/marbl/HG002). This assembly has been worked on by many leading people in the field. And while it is undergoing polishing and is talked about as a draft, it is gapless outside of rDNA arrays and is very good. This makes HG002 a very good sample for testing assembly processes. You can always go back and compare your results against the draft from the T2T consortium.

# Graph Building: PacBio & ONT Data

We are going to start by introducing the two long read sequencing technologies that we will be using: PacBio's HiFi and Oxford Nanopore's Ultralong. These two technologies are complementary and each have their own strengths leading. You can answer some questions more easily with HiFi and some more easily with ONT UL. They can also be used together and this is important for the concept of a hybrid assembly algorithm where accurate reads are used to create a draft assembly and long reads are used to extend that assembly. 

In this section we will learn about both technologies then we create plots showing their characteristic read lengths and qualities. This will help us get a feel for what the data actually looks like in the wild. Lastly we will prepare this data for use in our assembly section.

This section is important because as someone who is about to make an assembly you have the most control over what type of data you put into the assembly algorithm. The more you know about the data, the better your assembly will be.


## PacBio Hifi: Illumina-Like Quality With Long Reads
**What is PacBio HiFi**
Pacbio's high fidelity (or HiFi) reads are long (~15kb) and accurate (~99.9%). PacBio produces such high quality reads (with their single-molecule real-time, or SMRT, sequencing) by reading the same sequence over and over again in order to create a circular consensus sequence (or CCS) as shown below. 

**PacBio's CCS Process**
![PacBio CCS Process](https://raw.githubusercontent.com/human-pangenomics/hprc-tutorials/GA-workshop/assembly/genomics_aotearoa/images/sequencing/HiFi-reads-img.svg)

Long, highly accurate reads allows for a number of analyses that were difficult or impossible in the context of short reads. For instance, variants can be more easily phased as you can just look for variants that are seen in the same sequencing read. In our context, long accurate reads allow assembly algorithms to build assembly graphs across difficult regions. But it turns out that HiFi reads aren't long enough to span exact repeats in regions like human centromeres.

## ONT Ultralong: Lower Quality But Really Long Reads
Oxford Nanopore's ultralong (UL) sequencing has lower accuracy (~97%), but is really long (even longer than normal ONT). This is achieved though a different library prep -- as compared to normal DNA sequencing with ONT. UL library prep uses a transposase to cut DNA at non specific sites where it can then be adapted for sequencing. 

**ONT Ultralong Library Prep**
<p align="center">
    <img src="https://raw.githubusercontent.com/human-pangenomics/hprc-tutorials/GA-workshop/assembly/genomics_aotearoa/images/sequencing/ULK114_workflow_V1-3.svg" width="350"/>
</p>


The time, transposase amount, and temperature are all factors that effect transposase activity. The more you cut, the shorter the reads. ONT's standard DNA library prep, on the other hand, shears DNA then ligates adapters. (If you've created DNA libraries using Illumina's TruSeq kits, then you get the idea.)

These UL reads, while less accurate than HiFi, span tricky regions making UL and HiFi data highly complementary, especially in the context of denovo assembly, as we will see.

## Familiarize Ourselves With The Data
Let's get our hands on some data so we can see with our own eyes what HiFi and UL data look like.

**Create A Directory**
```
cd ~/lra
mkdir day1_data
cd day1_data
```
**Load modules**
```
module load pigz/2.7
module load NanoComp/1.20.0-gimkl-2022a-Python-3.10.5
```
**Subset Our Input Data**<br>
In order to get a feel for the data we only need a small portion of it. Pull the first few thousand reads and write them to new files.
```
zcat /nesi/nobackup/nesi02659/LRA/resources/LRA_hifi.fq.gz \
    | head -n 200000 \
    | pigz > LRA_hifi_50k_reads.fq.gz &
```
Also downsample the UL reads
```
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
        <strong>What is the range of Q-scores seen in HiFi data?</strong>
    </summary>
    While most HiFi data is Q30, there is a spread. The CCS process actually produces different data based on a number of different factors including the number of times a molecule is read (also called subread passes). Raw CCS data is usually filtered for >Q20 reads at which point it is by convention called HiFi. (Note that some people use CCS data below Q20!)
</details>

<details>
    <summary>
        <strong>What percent of UL reads are over 100kb?</strong>
    </summary>
    This depends on the dataset but it is very common to see 30% of reads being over 100kb. The 100kb number gets passed around a lot because reads that are much longer than HiFi are when UL distinguishes itself.
</details>

# Cleaning Data For Assembly
## PacBio Adapter Trimming
PacBio's CCS software attempts to identify adapters and remove them. This process is getting better all the time, but some datasets (especially older ones) can have adapters remaining. If this is the case adapters can find their way into the assemblies. 

Run CutAdapt to check for adapter sequences**
 in the downsampled data that we are currently using. (The results will print to stdout on your terminal screen.)
```
module load cutadapt/4.1-gimkl-2022a-Python-3.10.5

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
Notice that we are writing output to `/dev/null`. We are working on a subset of these reads so the runtime is reasonable. There is no need to hold onto the reads that we are filtering on just a subset of the data.

<details>
    <summary>
        <strong>What do you think the two sequences that we are filtering out are? (hint: you can Google them)</strong>
    </summary>
    The first sequence is the primer and the second sequence is the hairpin adapter. You can see the hairpin by looking at the 5' and 3' ends and checking that they are reverse complements.
</details>

<details>
    <summary>
        <strong>Why can we get away with throwing away entire reads that contain adapter sequences?</strong>
    </summary>
    As you can see from the summary statistics from CutAdapt, not many reads in this dataset have adapters/primers. There is some concern about bias -- where we remove certain sequences from the genome assembly process. We've taken the filtered reads and aligned them to the genome and they didn't look like they were piling up in any one area.
</details>

<details>
    <summary>
        <strong>What would happen if we left adapter sequences in the reads?</strong>
    </summary>
    If there are enough adapters present, you can get entire contigs comprised of adapters. This is not the worst, actually because they are easy to identify and remove wholesale. It is trickier (and this happens more often) when adapter sequences end up embedded in the final assemblies. If/when you upload assemblies to repositories like Genbank they check for these adapters and force you to mask them out with N's. This is confusing to users because it is common to use N's to signify gaps in scaffolded assemblies. So users don't know if they are looking at a scaffolded assembly or masked out sequence.
</details>


## ONT Read Length Filtering
Hifiasm is often run with ONT data filtered to be over 50kb in length, so let's filter that data now to see how much of the data remains. 
```
seqkit seq \
    -m 50000 \
    LRA_ONTUL_1k_reads.fq.gz \
    | pigz > LRA_ONTUL_1k_reads.50kb.fq.gz &
```
Now we can quickly check how many reads are retained
```
zcat LRA_ONTUL_1k_reads.50kb.fq.gz | wc -l
```

<details>
    <summary>
        <strong>Why do you think an assembler might want to include only reads over 50kb?</strong>
    </summary>
    
</details>

# Phasing Data: Trio DBs and Hi-C
Now that we've introduced the data that creates the graphs, it's time to talk about data types that can phase them in order to produce fully phased diploid assemblies (in the case of human assemblies). 

## Trio Data
At the moment the easiest and most effective way to phase human assemblies is with trio information. Meaning you sequence a sample, then you also sequence its parents. You then look at which parts of the genome the sample inherited from one parent and not the other. This is done with kmer DBs. In our case with either Meryl (for Verkko) or YAK (for Hifiasm) so let's take a moment to learn about kmer DBs.

### Meryl
[Meryl](https://github.com/marbl/meryl) is a kmer counter that dates back to Celera. It creates kmer databases (DBs) but it is also a toolset that you can use for finding kmers and manipulating kmer count sets. Meryl is to kmers what BedTools is to genomic regions.

Today we want to use Meryl in the context of creating databases from PCR-free Illumina readsets. These can be used both during the assembly process and during the post-assembly QC. 

**Some background on assembly phasing with trios**

Verkko takes as an input what are called hapmer DBs. These are constructed from the kmers that a child inherits from one parent and not the other. These kmers are useful for phasing assemblies because if an assembler has two very similar sequences it can look for maternal-specific kmers and paternal-specific kmers and use those to determine which haplotype to assign to each sequence.

<p align="center">
    <img src="https://github.com/human-pangenomics/hprc-tutorials/blob/GA-workshop/assembly/genomics_aotearoa/images/sequencing/meryl_venn.png?raw=true" width="350"/>
</p>

In the venn diagram above, the maternal hapmer kmers/DB are on the left-hand side (in the purple in red box). The paternal hapmer kmers/DB are on the right-hand side (in the purple in blue box). 

#### Let's start by just familiarizing ourselves with Meryl's functionality...

**Create a directory**
```
cd ~/lra
mkdir day1_data/meryl
cd day1_data/meryl
```

**Now create a small file to work with**
```
zcat /nesi/nobackup/nesi02659/LRA/resources/ilmn/pat/HG003_HiSeq30x_subsampled_R1.fastq.gz \
    | head -n 20000000 \
    | pigz > HG003_HiSeq30x_20M_reads_R1.fastq.gz &
```    

**Create a kmer DB from an Illumina read set**
```
module load Merqury/1.3-Miniconda3

meryl count \
    compress \
    k=30 \
    threads=4 \
    memory=8 \
    HG003_HiSeq30x_20M_reads_R1.fastq.gz \
    output paternal_20M_compress.k30.meryl
```

This should be pretty fast because we are just using a small amount of data to get a feel for the program. The output of Meryl is a folder that contains 64 index files and 64 data files. If you try and look at the data files you'll see that they aren't human readable. In order to look at the actual kmers, you have to use meryl to print them.

**Look at the kmers**
```
meryl print \
    greater-than 1 \
    paternal_20M_compress.k30.meryl \
    | head
```
The first column is the kmer and the second column is the count of that kmer in the dataset.

**Take a look at some statistics for the DB**
```
meryl statistics \
    paternal_20M_compress.k30.meryl \
    | head -n 20
```

We see a lot of kmers missing and the histogram (frequency column) has a ton of counts at 1. This makes sense for a heavily downsampled dataset. Great. We just got a feel for how to use Meryl in general on subset data. Now let's actually take a look at how to create Meryl DBs for Verkko assemblies.

#### How would we run Meryl for Verkko?

**Here is what the slurm script would look like:**

(Don't run this, it is slow! We have made these for you already.
```
#!/bin/bash -e

#SBATCH --account       nesi02659
#SBATCH --job-name      meryl_run
#SBATCH --cpus-per-task 32
#SBATCH --time          12:00:00
#SBATCH --mem           96G
#SBATCH --output        slurmlogs/test.slurmoutput.%x.%j.log
#SBATCH --error         slurmlogs/test.slurmoutput.%x.%j.err


module purge
module load Merqury/1.3-Miniconda3

## Create mat/pat/child DBs
meryl count compress k=30 \
    threads=32 memory=96 \
    maternal.*fastq.gz \
    output maternal_compress.k30.meryl

meryl count compress k=30 \
    threads=32 memory=96 \
    paternal.*fastq.gz \
    output paternal_compress.k30.meryl

meryl count compress k=30 \
    threads=32 memory=96    \
    child.*fastq.gz output    \
    child_compress.k30.meryl

## Create the hapmer DBs
$MERQURY/trio/hapmers.sh \
  maternal_compress.k30.meryl \
  paternal_compress.k30.meryl \
     child_compress.k30.meryl
```

#### Closing notes

**Meryl DBs for Assembly and QC**
It should be noted that Meryl DBs used for assembly with Verkko and for base-level QC with Merqury are created differently. Here are the current recommendations for kmer size and compression:
* Verkko: use `k=30` and the `compress` command.
* Merqury: use `k=21` and do not include the `compress` command

<details>
    <summary>
        <strong>Why does Verkko use compressed Meryl DBs while Merqury does not?</strong>
    </summary>
    The biggest error type from long read sequencing comes from homopolymer repeats. So assembly graphs are typically constructed from homopolymer compressed data. After the assembly graph is created the homopolymers are added back in. Verkko compresses the HiFi reads for you, but you need to give it homopolymer compressed Meryl DBs so they play nicely together. Merqury on the other hand is used to assess the quality of the resultant assembly, so you want to keep those homopolymers in order to find errors in them.
</details>

<details>
    <summary>
        <strong>Why does Merqury use k=21</strong>
    </summary>
    Larger K sizes give more conservative results, but this comes at a cost since you get lower effective coverage. For non-human species, if you know your genome size you can [estimate an optimal K using Meryl itself](https://github.com/marbl/merqury/wiki/1.-Prepare-meryl-dbs#1-get-the-right-k-size). If you are wondering, Verkko uses k=30 in order to be "conservative". And at the time of writing this document, different species typically stick with k=30. Though this hasn't been tested, so it may change in the future.
</details>

<details>
    <summary>
        <strong>Do Meryl DBs have to be created from Illumina data? Could HiFi data be used an an input to Meryl?</strong>
    </summary>
    They don't! You can create a Meryl DB from 10X data or HiFi data, for instance. The one caveat is that you want your input data to have a low error rate. So UL ONT data wouldn't work.
</details>

**Other things you could do with Meryl**

Here is an example of something you could do with Meryl:
* You can create a kmer DB from an assembly
* You could then print all kmers that are only present once (using `meryl print equal-to 1`) 
* Then write those out to a bed file with `meryl-lookup`. 
Now you have "painted" all of the locations in the assembly with unique kmers. That can be a handy thing to have lying around.

## Hi-C
Hi-C is a proximity ligation method. It takes intact chromatin and locks it in place, cuts up the DNA, ligates strands that are nearby and then makes libraries from them. It's easiest to just take a look at a cartoon of the process.
![Hi-C Library Flow](https://github.com/human-pangenomics/hprc-tutorials/blob/GA-workshop/assembly/genomics_aotearoa/images/sequencing/hi-c-flow-2.png?raw=true)

Given that Hi-C ligating molecules that are nearby it can be used for spatial genomics applications. In assembly we take advantage of the fact that most nearby molecules are on the same strand (or haplotype) of DNA. 

<details>
    <summary>
        <strong>What are the advantage of trio phasing over Hi-C?</strong>
    </summary>
    Trio data is great for phasing because you can assign haplotypes to maternal and paternal bins. This has the added benefit of assigning all maternal contigs to the same assembly. Hi-C ensure that an entire chromosome is phased into one haplotype, but across chromosomes the assignment is random. 
</details>

<details>
    <summary>
        <strong>So why wouldn't you always use trio data for phasing?</strong>
    </summary>
    It can be hard to get trio data. If a sample has already been collected it may be hard to go back and indentify the parents and collect sample from them. In non-human samples, trios can also be difficult. 
</details>

<details>
    <summary>
        <strong>Are there any difficulties in preparing Hi-C data?</strong>
    </summary>
    Yes! As you can see in the cartoon above Hi-C relies on having intact chromatin as an input. This means that cell lines are an excellent input source, but frozen blood is less good, for instance.
</details>



## Other Datatypes
We should also mention that there are other datatypes that can be used for phasing, though they are less common.

### Pore-C
Pore-C is a variant of Hi-C which retains the chromatin conformation capture, but the sequencing is done on ONT. This allows long reads sequencing of concatemers. Where Hi-C typically has at most one "contact" per read, Pore-C can have many. The libraries also do not need to be amplified so Pore-C reads can carry base modification calls. 

### StrandSeq
StrandSeq is a technique that creates sparse Illumina datasets that are both cell- and strand-specific. Cell specificity is achieved by putting one cell per well into 384 well plates (often multiple). Strand specificity is achieved through selective fragmentation of nascent strands. (During DNA replication, BrdU is incorporated exclusively into nascent DNA strands. In the library preparation the BrdU strand is fragmented and only the other strand amplifies.) This strand specificity gives another way to identify haplotype-specific kmers and use them during assembly phasing.

If you are interested in these phasing approaches, you can read more about them in the following articles:
> Lorig-Roach, Ryan, et al. "Phased nanopore assembly with Shasta and modular graph phasing with GFAse." bioRxiv (2023): 2023-02.

> Porubsky, David, et al. "Fully phased human genome assembly without parental data using single-cell strand sequencing and long reads." Nature biotechnology 39.3 (2021): 302-308.