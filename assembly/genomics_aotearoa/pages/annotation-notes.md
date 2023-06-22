# Day 3b: Genome Annotation

A genome assembly &ndash; even a very good one &ndash; is of limited utility
without annotation to provide context about the raw bases. Broadly speaking, an
annotation is any information about some region of the genome, e.g., the GC% in
a given window or whether and in which way a particular region is repetitive.
Accordingly, annotation techniques, computational resources, input requirements,
and output formats can vary widely.  However, the term "annotation" typically
refers to the more specific case of locating the protein-coding genes, ideally
specifying features such as exon-intron boundaries, untranslated regions (UTRs),
splice variants, etc. Accordingly, we will focus on this type of annotation
here.

When annotating genes, many methods and tools are available, depending on your
objective. When planning a project, you might ask yourself: Do I want
<abbr title="Structural annotation describes the structure of the gene or
transcript, e.g., exon-intron boundaries, UTRs, etc.">structural
annotation</abbr>, <abbr title="Functional annotation describes the known or
anticipated function, e.g., protein-coding, gene <X> or part of <X> gene family,
similar to <Y> organism's <Z> gene, etc.">functional annotation</abbr>, or both?
Do I want to locate genes using _de novo_ prediction models, transcript- or
RNA-seq-based evidence, or both? Do I have a reliable source of annotations from
the assembly of a related genome? Do I have a collaborator willing and able to
perform the annotation for me?

A full discussion or tutorial covering the various scenarios is beyond the scope
of this workshop, but pipelines like
[MAKER](https://yandell-lab.org/software/maker.html) (Holt and Yandell, 2011;
doi: [10.1186/1471-2105-12-491](https://doi.org/10.1186/1471-2105-12-491)) can
be configured to do many of these things, though installing all necessary
dependencies can be challenging in some circumstances. Many tools also assume
short reads (e.g., when using RNA-seq evidence), and incorporating information
from long-read sources may require adjustments.

Here we will get a taste for annotation with one popular tool: Liftoff, which
makes use of another genome assembly with annotations you wish to "copy" onto
your assembly.

<details>
	<summary>
		<strong>What is the easiest way to annotate my genome of interest?</strong>
	</summary>
	The easiest way to get a genome annotated is to have someone else do it. If
	sharing data with NCBI is possible and your assembly is the best option to
	represent your species of interest, they may be willing to annotate your
	genome for you using
	<a href="https://www.ncbi.nlm.nih.gov/genome/annotation_euk/process/">their pipeline</a>.
	Otherwise, finding a collaborator with expertise is a good option.
</details>

<details>
	<summary>
		<strong>What are the most common formats for sharing annotation data?</strong>
	</summary>
	The most common formats are
	<a href="https://genome.ucsc.edu/FAQ/FAQformat.html#format1">BED (Browser Extensible Data)</a>,
	<a href="https://gmod.org/wiki/GFF3">GFF (Generic Feature Format; v3)</a>,
	<a href="https://gmod.org/wiki/GFF2">GTF (General Transfer Format; a.k.a., deprecated GFF v2)</a>,
	and custom TSV (tab-separated value).
	<a href="http://genome.cse.ucsc.edu/goldenPath/help/wiggle.html">Wiggle</a>
	format and its variants are also common for displaying information in a genome
	browser.
</details>

<details>
	<summary>
		<strong>Which tool(s) should I use for my project?</strong>
	</summary>
	Annotation is a complex problem, and no single tool exists that can be
	universally recommended. A high-quality annotation plan often requires the
	use of may tools and/or complex pipelines, and the installation of many of
	these tools can be complicated, even for expert command-line users.
	Generally speaking, following the best-practice of those in your field or
	who work on the same taxa is a reasonable option. In some cases, tools
	specific to some set of organisms have been developed (e.g., <a
	href="https://funannotate.readthedocs.io/">Funannotate</a> for fungi).
	Recently, the <a href="https://github.com/Gaius-Augustus/BRAKER">BRAKER</a>
	team released version 3 of their pipeline for gene structure prediction
	(wrapping GeneMark-ES/ET & AUGUSTUS). If you have a trustworthy source of
	annotations from another assembly, you can consider <a
	href="https://github.com/agshumate/Liftoff">Liftoff</a> and <a
	href="https://github.com/ComparativeGenomicsToolkit/Comparative-Annotation-Toolkit">CAT</a>.
	<a
	href="https://www.ebi.ac.uk/interpro/about/interproscan/">InterProScan</a>
	can give you functional annotations relatively quickly. If you are able to
	share your data with NCBI and your assembly is the best assembly (or if the
	community agrees it is otherwise preferred), they NCBI annotation team will
	annotate it for you using their automated pipeline. <a
	href="https://gff3toolkit.readthedocs.io/">GFF3 Toolkit</a> can be useful
	when working with GFF3 files, and <a
	href="https://gfacs.readthedocs.io">gFACs</a> can help with filtering,
	analysis, and conversion tasks.
</details>

<details>
	<summary>
		<strong>How can I learn more about annotation?</strong>
	</summary>
	Please consider the following sources:
	<ul>
		<li>
			Review of eukaryotic genome annotation written for beginners
			(Yandell and Ence, 2012; doi:
			<a href="https://doi.org/10.1038/nrg3174">10.1038/nrg3174</a>)
		</li>
		<li>
			Review of assembly and annotation written for conservation
			geneticists and assuming limited understanding of bioinformatics and
			high-throughput sequencing (Ekblom and Wolf, 2014; doi:
			<a href="https://doi.org/10.1111/eva.12178">10.1111/eva.12178</a>)
		</li>
		<li>
			Review of structural and functional annotation, providing
			definitions and the limitations of annotation (Mudge and Harrow,
			2016; doi: <a href="https://doi.org/10.1038/nrg.2016.119">10.1038/nrg.2016.119</a>)
		</li>
		<li>
			Protocol (from <a href="https://www.protocols.io">protocols.io</a>)
			for <em>de novo</em> annotation using the <a
			href="https://yandell-lab.org/software/maker.html">MAKER</a>
			pipeline. This is annotation "in the wild" describing actual steps
			taken if not the justification for them, but it is based on this <a
			href="https://weatherby.genetics.utah.edu/MAKER/wiki/index.php/MAKER_Tutorial_for_WGS_Assembly_and_Annotation_Winter_School_2018">2018
			tutorial</a> by the developers of MAKER. <a
			href="https://doi.org/10.17504/protocols.io.b3xvqpn6">The
			protocol</a> was used to annotate a non-model fish genome (Pickett
			and Talma <em>et al.</em>, 2022; doi: <a
			href="https://doi.org/10.46471/gigabyte.44">10.46471/gigabyte.44</a>).
		</li>
	</ul>
</details>

## Annotation with Liftoff

According to the
[Liftoff GitHub Repository](https://github.com/agshumate/Liftoff):
> Liftoff is a tool that accurately maps annotations in GFF or GTF between
> assemblies of the same, or closely-related species. Unlike current coordinate
> lift-over tools which require a pre-generated "chain" file as input, Liftoff
> is a standalone tool that takes two genome assemblies and a reference
> annotation as input and outputs an annotation of the target genome. Liftoff
> uses Minimap2 (Li, 2018; doi:
> [10.1093/bioinformatics/bty191](https://doi.org/10.1093/bioinformatics/bty191))
> to align the gene sequences from a reference genome to the target genome.
> Rather than aligning whole genomes, aligning only the gene sequences allows
> genes to be lifted over even if there are many structural differences between
> the two genomes. For each gene, Liftoff finds the alignments of the exons
> that maximize sequence identity while preserving the transcript and gene
> structure. If two genes incorrectly map to overlapping loci, Liftoff
> determines which gene is most-likely mis-mapped, and attempts to re-map it.
> Liftoff can also find additional gene copies present in the target assembly
> that are not annotated in the reference.

We will use Liftoff (doi:
[10.1093/bioinformatics/btaa1016](https://doi.org/10.1093/bioinformatics/btaa1016))
lift over the annotations from the T2T-CHM13 reference assembly to our assembly
of HG002.

**Create directory**

```shell
mkdir liftoff-annotation
cd liftoff-annotation
```

**Gather the necessary files**

```shell
ln -s /path/to/chm13-annotations-file.gff chm13-annotations.gff
ln -s /path/to/chm13-reference.fasta chm13.fa
ln -s /path/to/my-hg002-asm-from-this-workshop/assembly.fasta asm.fa
```

**Run Liftoff**

```shell
liftoff \
	-p ${THREADS} \
	-g chm13-annotations.gff \
	-o asm.annotations.gff \
	asm.fa \
	chm13.fa
```

<!-- OTHER POSSIBLE OPTIONS
	-u unmapped_features.txt
	-m /path/to/minimap2-installation/bin/minimap2
	-infer_genes -OR- -infer_transcripts # depending on what the chm13-annotations.gff looks like
	-chroms chromosomes.csv
	-unplaced unplaced_seq_names.txt
	-copies # possibly with -sc 2 # diploid vs haploid assembly liftover
-->

<details>
	<summary>
		<strong>What do each of these options do?</strong>
	</summary>
	<code>-p</code> specifies the number of threads to use. <code>-g</code> specifies the location of
	the GFF file with the input annotations for the reference. <code>-o</code> specifies
	the location of the GFF file with the output annotations for the target.
	The two positional parameters at the end are respectively the target
	assembly (our HG002 assembly) and the reference assembly (T2T-CHM13). Run
	the following command to see all the options described in more detail:
	<pre><code>liftoff -h</code></pre>
</details>

**Look at the output GFF3 file**

```shell
less -S asm.annotations.gff
```

**Visualize the annotations in a genome browser**

1. Open IGV
2. TODO
3. TODO
4. TODO

**Take Home**

TODO

