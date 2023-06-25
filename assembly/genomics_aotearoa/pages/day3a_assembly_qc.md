# Day 3a: Assembly Quality Control (QC)
Now that we have understood our data types (day 1) and put them through an assembly algorithm (day 2), we have this file of A's, T's, C's, and G's, that's supposed to be our assembly. This file is supposed to represent a biological reality, so let's try to assess its quality through several lens, some biological and some more technical. One way to remember the ways we evaluate assemblies is by thinking about the "3C's": contiguity, correctness, and completeness.

!!! question "Exercises"
```
- What do you think a 'good' de novo assembly looks like?
- What are some qualities of an assembly that you might be interested in measuring?
```

## Contiguity (assembly statistics using gfastats)
Recall that the sequences in our assembly are referred to as *contigs*. 

Normally, when we receive a hodgepodge of things with different values of the same variable, such as our contigs of varying lengths, we are inclined to use descriptive statistics such as average or median to try to get a grasp on how our data looks. However, it can be hard to compare average contig length between assemblies -- if they have the same total size and same number of contigs, it's still the same average, even if it's five contigs of 100 bp, or one 460 bp contig and four 10 bp ones! This matters for assembly because ideally we want *fewer* contigs that are *larger*. 

Median comes closer to reaching what we're trying to measure, but it can be skewed by having many very small contigs, so instead a popular metric for assessing assemblies is *N50*.

The N50 is similar to the median in that one must first sort the numbers, but then insted of taking the middle value, the N50 value is the *length of the first contig that is equal to or greater than half of the assembly sum*. But that can be hard to understand verbally, so let's look at it visually:

["../images/qc/N50.png"](image)
*Image adapted from <a href='https://www.molecularecologist.com/2017/03/29/whats-n50/'>Elin Videvall at The Molecular Ecologist</a>.* 

The N50 can be interpreted as such: given an N50 value, 50% of the sequence in that assembly is contained in contigs of that length or longer. Thus, N50 has been traditionally used as the assembly statistic of choice for comparing assemblies, as it's more intuitive (compared to average contig length) to see that an assembly with an N50 value of 100Mbp is more contiguous than one with an N50 value of 50MBp, since it seems like there are more larger contigs in the former assembly.

Another statistic that is often reported with N50 is the *L50*, which is the index value of the contig that gives the N50 value. For instance, in the above image, the L50 would be 3, because it would be the third largest contig that gives the N50 value. L50 is useful for contextualizing the N50, because it gives an idea of how many contigs make up that half of your assembly. 

Given how the N50 value can be so affected by addition or removal of small contigs, another metric has come into use: the area under the (N50) curve, or the auN value. 

Let's get some basic statistics for our assembly using a tool called *gfastats*, which will output .
```
gfastats -t test.p_ctg.fa
```



Remember, though, that the file we initially got was an assembly *graph* -- what if we wanted to know some graph-specitic stats about our assembly, such as number of nodes or disconnected components? We can also assess that using gfastats.

```
gfastats -t test.p_ctg.gfa
```


## Correctness (QV using Merqury)
COMPLETENESS INTRO

We'll use Merqury to calculate QV [EXPLAINER?]:
```
## merqury (qv) might need to check submit scripts to see if work
sbatch -c[cores] merqury.sh \
    [readDB.meryl]          \
    [asm.fasta]             \
    [output]
### if we want to run merqury with the paternal info too, I like looking at blob plots to understand phasing
sbatch -c[cores] merqury.sh \
    [readDB.meryl]          \
    [pat hapmer DB]         \
    [mat hapmer DB]         \
    [asm.fasta]             \
    [output]
```

If we have parental data, we can also evaluate for switch errors using yak..
```
## yak trioeval for switch errors
yak trioeval -t [threads] \
    [pat.yak] [mat.yak]   \
    [asm.fasta]           \
    > trioeval.out
```

## Completeness (gene content using asmgene)

```
## asmgene
minimap2 -cxsplice:hq -t[threads] \
    [ref.fasta] GCF_009914755.1_T2T-CHM13v2.0_cds_from_genomic.fna \
    > ref.cdna.paf
minimap2 -cxsplice:hq -t[threads] \
    [asm.fasta] GCF_009914755.1_T2T-CHM13v2.0_cds_from_genomic.fna \
    > asm.cdna.paf
k8 paftools.js asmgene [-a] [ref.cdna.paf] [asm.cdna.paf]
```

Another popular tool for checking genome completeness using gene content is the software Benchmarking Universal Single-Copy Orthologs (BUSCO). This approach uses a set of evolutionarily conserved genes that are expected to be present at single copy for a given taxa, so one could check their genome to see if, for instance, it has all the genes predicted to be necessary for *Aves* or *Vertebrata*. This approach is useful if your de novo genome assembly is for a species that does not have a reference genome yet. 

