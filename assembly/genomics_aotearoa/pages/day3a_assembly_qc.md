# Day 3a: Assembly Quality Control (QC)
Now that we have understood our data types (day 1) and put them through an assembly algorithm (day 2), we have this file of A's, T's, C's, and G's, that's supposed to be our assembly. This file is supposed to represent a biological reality, so let's try to assess its quality through several lens, some biological and some more technical. One way to remember the ways we evaluate assemblies is by thinking about the "3C's": contiguity, correctness, and completeness.

!!! question "Exercises"
```
- What do you think a 'good' de novo assembly looks like?
- What are some qualities of an assembly that you might be interested in measuring?
```

## Contiguity (assembly statistics using gfastats)
Recall that our sequences in the assembly are referred to as *contigs*. 

Let's try to get some basic statistics for our assembly.
```
gfastats -t test.p_ctg.fa
```
FASTA STATS EXPLAINER
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

