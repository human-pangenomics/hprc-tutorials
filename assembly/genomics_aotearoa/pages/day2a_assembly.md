<!-- # Background on HiFi+UL Assemblers
## Verkko Process
Figure from paper
## Hifiasm Process
Figure from paper
 -->
# Playing With Test Data
Running assemblers is very computationally intensive and the output files can be big. Let's not jump straight into assembling human genomes. Instead we can use the test data that both assemblers provide as a way to both ensure that we know how to run the tool (which is easy) and we can start to get a feel for the process and outputs in real life. 
## Run Hifiasm With Test Data

**Create A Directory**
```
cd ~
mkdir -p day2_assembly/hifiasm_test
cd day2_assembly/hifiasm_test
```

**Now download Hifiasm's test data**<br>
```
wget https://github.com/chhylp123/hifiasm/releases/download/v0.7/chr11-2M.fa.gz
```
This is HiFi data from about 2 million bases of chromosome 11. Hifi data is the only required data type for Hifiasm and Verkko. You can create assemblies from only Hifi data and you can add ONT and phasing later. Also notice that this data is in fasta format! Presumably this is to make the file smaller since this is test data.

Now let's load the hifiasm module
```
module purge
module load hifiasm
```
And actually run the test data
```
hifiasm \
    -o test \
    -t4 \
    -f0 \
    chr11-2M.fa.gz \
    2> test.log &
```
This should take around 3 minutes. Once the run is complete take a look at the top of the log:
```
head -n 60 test.log
```
Now check the [hifiasm log interpretation](https://hifiasm.readthedocs.io/en/latest/interpreting-output.html#hifiasm-log-interpretation) section of the documentation to give that some context.

<details>
    <summary>
        <strong>What does the histogram represent, and how many peaks do you expect?</strong>
    </summary>    
    The histogram represents the kmer count in the hifi reads. For humans we expect to see a large peak somewhere around our expected sequencing coverage: this represents homozygous kmers. The smaller peak represents heterozygous kmers.
</details>

Now `ls` the directory to see what outputs are present. What do you see? No fasta files, but there are a lot of files that  end in `gfa`. If you haven't seen these before, then we get to introduce you to another file format! 

### Introduction To GFA Files
GFA stands for [Graphical Fragment Alignment](http://gfa-spec.github.io/GFA-spec/GFA1.html) and Hifiasm outputs assemblies in GFA files. GFAs aren't like bed or sam files which have one entry per line (or fasta/q that have 2/4 lines per entry). But this is bioinformatics, so you can rest assured that it is just a text file with a new file extension. It's easiest to just look at an example of a GFA file from the spec:

```
H    VN:Z:1.0
S   11  ACCTT
S   12  TCAAGG
S   13  CTTGATT
L   11  +   12  -   4M
L   12  -   13  +   5M
L   11  +   13  +   3M
P   14  11+,12-,13+ 4M,5M
```
**Here we see the following line types**
* H (Header): File header. You get the idea.
    * The example here the header is just saying that the file follows GFA 1.0 spec. 
    * Notice that this line follows a TAG:TYPE:VALUE convention. Type in this case is Z which corresponds to printable string. 
* S (Segment): A sequence of DNA
    * This is what we care about for the moment!
* L (Link): Overlap between two segments
    * We can read the first Link line as saying that the end of Segment 11 (+) connects to the beginning of Segment 12 (-) and the overlap is 4 matching bases. In this case it would look like this:
```    
    ACCTT    (Segment 11)
     ||||
     GGAACT  (Segment 12 -- reversed)
```
* P (Path): Ordered list of segments (connected by links)

**So how do we get a fasta from a GFA?**<br>
To get a fasta we just pull the S lines from a GFA and print them to a file:
```
awk '/^S/{print ">"$2;print $3}' \
    test.bp.p_ctg.gfa \
    > test.p_ctg.fa 
```
You can read this awk command as: 
1. Give me all input lines that start with `S` 
2. Then print the second column of those lines (which is the sequence ID) 
3. Also print another line with the actual sequence

<details>
    <summary>
        <strong>Why does Hifiasm output GFAs and not Fastas?</strong>
    </summary>    
    Hifiasm (and many other assemblers) use gfas while they are actually assembling. The gfa represents/stores the assembly graph. Hifiasm probably doesn't output fastas just because everything in the fasta is contained in the gfa, so why store it twice?
</details>



### View Hifiasm Test Assembly GFA in Bandage
We are going to take a look at the assembly gfa file in a browser called Bandage. Bandage provides a way to visualize something called unitig graphs.

**Start Bandage**
1. From your Jupyter session click the + icon to create a new tab.
2. Click the Virtual Desktop icon (this will open a new tab in your web browser)
3. In the Virtual Desktop, click on the terminal emulator icon (in your toolbar at the bottom of your screen)
4. Load the Bandage module with `module load Bandage`
4. Type `Bandage &` to start Bandage

**Load a unitig GFA**
1. Click the *File* dropdown then *Load Graph*
2. Navigate to our current folder (day2_assembly/hifiasm_test)
3. Select the `test.bp.r_utg.noseq.gfa` file and press the **Open** icon
4. Under **Graph Drawing** on the left-hand side click **Draw Graph**

Ok, so what are we looking at? The thick lines are nodes -- which in this case represent sequences. Since we loaded the unitig graph the sequences are unitigs. A unitig is a high confidence contig. It is a place where the assembler says "I know exactly what is going on here". The ends of unitigs are where it gets messy. At the ends, an assembler has choices to make about which unitig(s) to connect to next.

**Now load a contig GFA**<br>
Open the `test.bp.p_ctg.noseq.gfa` file to see how boring it is.

In general, when using Bandage people look at the unitig gfas (not contig gfas). An assembly is a hypothesis, and the contigs output by the assembler are its best guess at the correct haplotype sequence. The contigs don't show much information about the decisions being made, however. They are the output. We view unitig gfas so we can see the data structure at the point that the assembler was making tough decisions. 

**Here are some things you can do with Bandage**
1. Let's say you mapped a sample's ONT reads back onto that sample's denovo assembly and have identified a misjoin. You can open up bandage and find that  unitigs that went into the contig to see if it can be easily manually broken.
2. If you have a phased diploid assembly with a large sequence that is missing, you can look at the unitig gfa, color the nodes by haplotype, and see which sequences are omitted. Those sequences can then be analyzed and manually added into the final assembly.
3. You can label nodes with (hifi) coverage and inspect regions with low quality too see if they have low coverage as well. If so, you might want to throw them out. (This does happen, in particular for small contigs that assemblers tend to output.)

pbmm2 align -j 128 $referencepath $hifi_demux > $alignedbam

## Run Verkko With Test Data
**Create A Directory**
```
cd ~
mkdir -p day2_assembly/verkko_test
cd day2_assembly/verkko_test
```

**Now download Verkko's test data**<br>
```
curl -L https://obj.umiacs.umd.edu/sergek/shared/ecoli_hifi_subset24x.fastq.gz -o hifi.fastq.gz
curl -L https://obj.umiacs.umd.edu/sergek/shared/ecoli_ont_subset50x.fastq.gz -o ont.fastq.gz
```
You can see that this dataset is for ecoli and there is both HiFi and ONT data included.

We could follow what we did with Hifiasm and just run Verkko in our notebook environment like so:
```
module purge
module load verkko/1.3.1-Miniconda3

verkko \
    -d asm \
    --hifi ./hifi.fastq.gz \
    --nano ./ont.fastq.gz
```
but depending on how you created your notebook environment this command may crash it. That's ok, it gives us an opportunity to test running Verkko w/ Slurm.

**Create Slurm script for test Verkko run**

Start your favourite text editor
```
nano verkko_test.sl
```

And then paste in the following
```
#!/bin/bash -e

#SBATCH --account       nesi02659
#SBATCH --partition     milan
#SBATCH --job-name      test_verkko
#SBATCH --cpus-per-task 8
#SBATCH --time          00:15:00
#SBATCH --mem           24G
#SBATCH --output        slurmlogs/test.slurmoutput.%x.%j.log
#SBATCH --error         slurmlogs/test.slurmoutput.%x.%j.err

## load modules
module purge
module load verkko/1.3.1-Miniconda3


## run verkko
verkko \
    -d assembly \
    --hifi ./hifi.fastq.gz \
    --nano ./ont.fastq.gz
```

**Run verkko test**
```
sbatch verkko_test.sl
```
This should only take a few minutes to complete.

You can keep track of the run w/ the `squeue` command. (If you don't know your username, you can find it with `whoami`).
```
squeue -u myusername
```

**How does Verkko run?**

It turns out that if you run Verkko more than once or twice you will have to know a bit about how it is constructed. Verkko is a program that reads in the parameters you gave it and figures out a few things about your verkko installation and then creates a configuration file (`verkko.yml`) and a shell script (`snakemake.sh`). The shell script is then automatically executed.

Take a look at the shell script that was created for your run
```
cat assembly/snakemake.sh
```
It is just a call to snakemake!!! You can think of Verkko as a tool, but also as a pipeline because it is. This has some advantages. One is that if you know what Verkko is doing (which is somewhat achievable given that the snakemake rules guide you through Verkko's logic), you can add to it, or even swap out how Verkko performs a given step for how you'd like to do it. It also means that you can restart a run at any given step (if you made a mistake or if the run failed). Lastly, and maybe most importantly, snakemake supports Slurm as a backend. So if you have access to an HPC you could (and probably should) run verkko and allow it to launch Slurm jobs for you. (This is in contrast to what we just did which was to run a slurm job and just allow all jobs to run on the allocated resources that we requested for the entire run.)

**Now take a look at the jobs that were run**

You can view the stderr from the run in your slurm logs, or in snakemake's logs. Let's take a look at the top of the log:
```
head -n 35 assembly/.snakemake/log/*.log
```
This shows a list of snakemake jobs that will get executed for this dataset. There are a few things to note. The first is that for larger datasets some jobs will get executed many times (hence the count column). This dataset is small, so most jobs have count=1. The second thing to note is that these jobs are sorted alphabetically, so we can get a feel for scale, but it's a bit hard to figure out what Verkko is really doing.

Open the logs and scroll through them
```
less asm/.snakemake/log/*.log
```
You can see all of the snakemake jobs, in order, that were run. Even for this tiny dataset there are many. Since there are a lot of jobs, there are a lot of outputs, and these are organized (roughly) by snakemake rule. Take a look at the output folder in order to familiarize yourself with the layout.
```
ls -lh assembly
```

**Take a look at the initial hifi graph**

Open the `assembly/1-buildGraph/hifi-resolved.gfa` file in Bandage. You will see that it is already pretty good. There are only three nodes.

**Now take a look at the ONT resolved graph**

Open the `assembly/5-untip/unitig-normal-connected-tip.gfa` file in Bandage. Now our three nodes have been resolved into one. 

# Comparison of Runtime Parameters

## Hifiasm

Hifiasm is compiled into a single binary file, and, when executed, it manages all tasks and parallelism under one parent process. You can run it the same on a VM in the cloud or in an HPC. 

For a human sample with around 40X HiFi and 30X UL and either HiC or trio phasing Hifiasm can assemble with:
* 64 cores
* 240GB of memory (most samples will use less)
* Around 24 hours of total runtime

So Hifiasm takes about 1500 cpu hours to assemble this sample. On a cluster you can just execute the run command. If you are on a cloud and would like to take advantage of pre-emptible instances, you can break the run command into three parts (each take around 8 hours).


## Verkko

Verkko is written as a shell wrapper around a Snakemake pipeline. This has the advantages of easily restarting after failures and increased potential for parallelism in an HPC environment with multiple nodes available, but it is hard to profile all the individual tasks. If the cluster is not too busy a human assembly can finish in around a day. Most of the compute is done in the overlap and graph aligner jobs. So we can break the runtimes into steps that revolve around the big jobs. That looks something like this:

| <sub>**Step**</sub> | <sub>**CPUs**</sub> | <sub>**Shards**</sub> | <sub>**Time/Shard (est)**</sub> |<sub>**Total CPU Hours**</sub> |
| :-------- | :-------- | :------ | :------ | :------ |
| <sub> pre overlap </sub> | <sub> 24 </sub> | <sub> 1 </sub> | <sub> 3 </sub> |<sub> 72 </sub> |
| <sub> overlap </sub> | <sub> 8 </sub> | <sub> 600 </sub> | <sub> 1 </sub> |<sub> 4800 </sub> |
| <sub> create graph </sub> | <sub> 80 </sub> | <sub> 1 </sub> | <sub> 13 </sub> |<sub> 1040 </sub> |
| <sub> graph aligner </sub> | <sub> 12 </sub> | <sub> 100 </sub> | <sub> 2 </sub> |<sub> 2400 </sub> |
| <sub> complete asm </sub> | <sub> 64 </sub> | <sub> 1 </sub> | <sub> 12 </sub> |<sub> 768 </sub> |

This gives an estimate of around 9000 cpu hours for the same data as above. This is almost certainly an overestimate, but not by more than a factor of 2. 

Note that the runtime estimates for Hifiasm and Verkko don't consider the preparatory work of counting parental kmers with yak or meryl, which are necessary steps before running either in trio mode.
