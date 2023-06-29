# Phased Assemblies in Action

!!! info "Objectives"
```
- learn about different approaches to phasing
- generate a pseudohaplotype assembly, without using any additional phasing data
- generate a Hi-C-phased assembly
- identify QC metrics that can assess phasing of assemblies
```

### Recap

- previously learned about assembly QC -> now we need to apply it by interpreting QC to see if an assembly is phased

### Data set reminder

- placeholder



## Getting started
Remember that there is a "Key terms and concepts" box at the end of this document if you want to refresh any definitions!
### subheader
text

!!! info "Key terms and concepts"
```
- CONTIG: contiguous (i.e., gapless) sequence in an assembly
- PHASING: phasing aims to partition the contigs for an individual according to their haplotype of origin. This is typically done using raed data from the parents to identify parentally inherited alleles. Recent approaches incorporate long-range Hi-C linkage information from the same individual to phase contigs. 
- PSEUDOHAPLOTYPE ASSEMBLY: assembly consisting of long, phased haplotype blocks separated by regions where the haplotype cannot be distinguished.
- SWITCH ERROR: 
- PRIMARY ASSEMBLY:
- ALTERNATE ASSEMBLY:
```

# Visualizing Repeats using ModDotPlot

[ModDotPlot](https://github.com/marbl/ModDotPlot) <!--([Sweeten _et al._ 2023](https://doi.org/##############))-->
is a tool for visualizing tandem repeats using dot plots, similar to
[StainedGlass](https://mrvollger.github.io/StainedGlass)
([Vollger _et al._ 2022](https://doi.org/10.1093/bioinformatics/btac018)), but
using sketching methods to radically reduce the computational requirements.
Visualizing tandem repeats like this _requires_ an assembly that spans all the
repeat arrays and assembles them accurately, making this a potent example of
the benefits of combining highly-accurate, long reads (like PacBio HiFi) with
ultralong reads from ONT in the assembly process with 
[hifiasm](https://github.com/chhylp123/hifiasm)
([Cheng _et al._ 2022](https://doi.org/10.1038/s41587-022-01261-x)) or
[Verkko](https://github.com/marbl/verkko)
([Rautiainen _et al._ 2023](https://doi.org/10.1038/s41587-023-01662-6)). Take
a moment, and consider that. You _can&rsquo;t_ do this with reads alone (even
long reads). Mapping to a good reference (e.g., CHM13-T2T) for your species of
interest (if one exists) _won&rsquo;t_ work either because the alignment
software can&rsquo;t distinguish between repeat copies.

<details>
    <summary>
        <strong>What are sketching methods?</strong>
    </summary>
    <p>
        &ldquo;Sketching&rdquo; is a technique to create reduced-representations
        of a sequence. The most widely-known option for sketching is probably
        minimizers, made particularly popular with tools like
        <a href="https://lh3.github.io/minimap2">minimap2</a>
        (<a href="https://doi.org/10.1093/bioinformatics/bty191">Li 2018</a>),
        which applies minimizers to the alignment problem. Several variants to
        minimizers exist, e.g., syncmers and modimizers, the latter of which is
        used in ModDotPlot. Each sketching method has different properties
        depending on how they select the subsequence used to represent a larger
        area, whether they allow overlaps, whether a certain density of
        representative sequences is enforced in any given window, whether the
        neighboring windows are dependent on eachother, etc. In general, the
        representative sequences are found by sliding along the sequence and
        selecting a representative subsequence in the given window.
    </p>
    <p>
        Many other tools use sketching in some way, here are a few examples:
        <ul>
            <li>
                <a href="https://github.com/marbl/Mash">Mash</a>
                (<a href="https://doi.org/10.1186/s13059-016-0997-x">Ondov <em>et al.</em> 2016</a>)
            </li>
            <li>
                <a href="https://github.com/marbl/MashMap">MashMap</a>
                (<a href="https://doi.org/10.1101/2023.05.16.540882">Kille <em>et al.</em> 2023</a>)
            </li>
            <li>
                <a href="https://github.com/maickrau/MBG">MBG</a>
                (<a href="https://doi.org/10.1093/bioinformatics/btab004">Rautiainen &amp; Marschall 2021</a>)
                <strong>
                    &lt;-- Used in
                    <a href="https://github.com/marbl/verkko">Verkko</a>
                    (<a href="https://doi.org/10.1038/s41587-023-01662-6">Rautiainen <em>et al.</em> 2023</a>)!
                </strong>
            </li>
            <li>
                <a href="https://github.com/chhylp123/hifiasm">hifiasm</a>
                (<a href="https://doi.org/10.1038/s41587-022-01261-x">Cheng <em>et al.</em> 2022</a>)
            </li>
        </ul>
    </p>
</details>

We&rsquo;re going to run ModDotPlot on part of the Y chromosome from our
earlier assembly. First we&rsquo;ll need to identify the appropriate chunk,
which can be done a few different ways depending on the sequence you&rsquo;re
looking for. In our case, chrY often appears tied on only one end to chrX in
the Bandage plot, making it easy to identify the Y node (which is shorter than
the longer X node). This method may not get all of the Y chromosome because it
may be (and in our case is) in separate pieces (i.e., it isn&rsquo;t T2T). The
ideal way is to map some known sequence against your assembly or to may your
assembly against a known reference. Since we&rsquo;re using data from HG002,
we can map against the CHM13-T2T reference.

## Initial setup

**Make a directory to work in**

```
mkdir day3-moddotplot
cd day3-moddotplot
```

**Get the files**

```
ln -s /nesi/nobackup/nesi02659/LRA/resources/resources/chm13/chm13v2.0.fa chm13.fa
ln -s /nesi/nobackup/nesi02659/LRA/resources/resources/verkko_trio_prebaked/asm_hifiont/assembly.fasta hg002.fa
ln -s /nesi/nobackup/nesi02659/LRA/resources/resources/verkko_trio_prebaked/asm_hifiont/assembly.fasta.fai hg002.fa.fai
```

## Find chrY contigs with MashMap

**Do the alignments**

We&rsquo;ll do the alignments with [MashMap](https://github.com/marbl/MashMap)
([Kille _et al._ 2023](https://doi.org/10.1101/2023.05.16.540882)). This should
take ~3 minutes with 4 CPUs and should use <3 GB RAM.
```
module load MashMap/3.0.4-Miniconda3
mashmap -f "one-to-one" \
    -k 16 --pi 85 \
    -s 500000 -t 4 \
    -r chm13.fa \
    -q hg002.fa \
    -o hg2-x-chm13.ssv
```

<details>
    <summary>
        <strong>What do these parameters do?</strong>
    </summary>
    You can run <code>mashmap -h</code> to find out. Here are the options we
    used:
<pre><code>
-r <value>, --ref <value>
    an input reference file (fasta/fastq)[.gz]

-q <value>, --query <value>
    an input query file (fasta/fastq)[.gz]

-s <value>, --segLength <value>
    mapping segment length [default : 5,000]
    sequences shorter than segment length will be ignored

--perc_identity <value>, --pi <value>
    threshold for identity [default : 85]

-t <value>, --threads <value>
    count of threads for parallel execution [default : 1]

-o <value>, --output <value>
    output file name [default : mashmap.out]

-k <value>, --kmer <value>
    kmer size <= 16 [default : 16]

-f <value>, --filter_mode <value>
    filter modes in mashmap: 'map', 'one-to-one' or 'none' [default: map]
    'map' computes best mappings for each query sequence
    'one-to-one' computes best mappings for query as well as reference sequence
    'none' disables filtering</code></pre>
</details>

**View the output file**

```
less -S hg2-x-chm13.ssv
```

<details>
    <summary>
        <strong>Which contigs belong to chrY?</strong>
    </summary>
    <p>
        pat-0000204, pat-0000206, pat-0000209, pat-0000213, and pat-0000218 probably
        are chrY. Others may be as well, but it is difficult to tell without a more
        refined investigation.
    </p>
    <p>
        Having a hard time telling? Try determining what percentage of the contig is aligned.
        <pre><code>awk 'BEGIN{FS=" "; OFS="\t"; print "Contig", "Length", "Percent Identity", "Percent Aligned"}{print $1, $2, $10 "%", ($4-$3)/$2*100 "%"}' \
    hg2-x-chm13.ssv \
    | column -ts $'\t' \
    > hg2-x-chm13.annotated.txt
less -S hg2-x-chm13.annotated.txt</code></pre>
    </p>
    <p>
        It may also help to visualize the dot plot from MashMap of contigs
        along chrY:
        <img src="https://github.com/human-pangenomics/hprc-tutorials/blob/GA-workshop/assembly/genomics_aotearoa/images/assembly-in-action/mashmap_hg002-x-chm13_chrY.png?raw=true" alt="Dotplot of HG002 contigs against CHM13 chrY">
    </p>
</details>

## Create self dot plots for each contig
ModDotPlot is still in development, and it cannot currently support doing
multiple self comparisons at one time. We will need to create separate fasta
files for our contigs of interest.

**Create and index subset fastas**

```
for CTG in pat-00002{0{4,6,9},1{3,8}}
do
    samtools faidx ${CTG} hg002.fa > hg002.${CTG}.fa
    samtools faidx hg002.${CTG}.fa
done
```

**Run ModDotPlot**

On sequences of this size, ModDotPlot is relatively quick. It has a reasonable
memory footprint for sequences <10 Mbp, but memory usage can exceed 20 GB for
large sequences (>100 Mbp). Let&rsquo;s create a script to submit with
`sbatch`. Paste the following into `moddotplot.sh`:
```
#! /usr/bin/env bash

set -euo pipefail

module load ModDotPlot/2023-06-gimkl-2022a-Python-3.11.3

for CTG in pat-00002{0{4,6,9},1{3,8}}
do
    moddotplot \
        -k 21 -id 85 \
        -i hg002.${CTG}.fa \
        -o mdp_hg002-${CTG}
done
```

<details>
    <summary>
        <strong>What do these parameters do?</strong>
    </summary>
    You can run <code>moddotplot -h</code> to find out (and enjoy some excellent
    ASCII art). Here are the options we used:
<pre><code>Required input:
  -i INPUT [INPUT ...], --input INPUT [INPUT ...]
                        Path to input fasta file(s)

Mod.Plot distance matrix commands:
  -k KMER, --kmer KMER  k-mer length. Must be < 32 (default: 21)

  -id IDENTITY, --identity IDENTITY
                        Identity cutoff threshold. (default: 80)

  -o OUTPUT, --output OUTPUT
                        Name for bed file and plots. Will be set to input fasta file name if not provided. (default: None)</code></pre>
</details>

Then submit with `sbatch`:
```
sbatch -J moddotplot -N1 -n1 -c1 --mem=8G -t 0-00:15 -A nesi02659 -o %x.%j.log moddotplot.sh
```

**Inspect the output files**

First, take a look at the log file:
```
less -S moddotplot.*.log
```

Then note that for every run, we created `_HIST.png` and `_TRI.png` files. The
HIST files show the distribution of the Percent Identity of the alignments. The
TRI files show everything above (or below, depending on how you look at it) the
diagonal of the dotplot, rotated such that the diagonal is along the X-axis of
the plot. Go ahead a view these files now.

**What do you observe?**

