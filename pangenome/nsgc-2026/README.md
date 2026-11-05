# The Human Pangenome in Practice: Tools, Cases, and Clinical Impact for Genetic Counselors

This repository contains the hands-on materials from the Human Pangenome Reference Consortium (HPRC) workshop at the NSGC 2026 Annual Conference. This workshop is designed to be interactive and hands-on. It will include two activities where you will look at publicly available data in genome browsers and see how the use of a single reference genome can have limitations. The materials included in this workshop do not require coding experience.


![NSGC 2026](https://img.shields.io/badge/NSGC-2026-2b6cb0)

# Suggested preparation
While preparation is not required for this workshop, we strongly encourage attendees to review the following document prior, especially if you’re new to genome browsers or could use a quick refresher: [Suggested Preparation Handout](https://docs.google.com/document/d/1I85Vkac9pRWCRYco8cYCIcnUk-0fD3LHaHnETcUQnvg/edit?tab=t.0)


# Activities

## 1. Exploring Human Variation in the UCSC Genome Browser

**What you do:** Load HPRC assembly alignments and structural variant calls in the UCSC Genome Browser. Then explore three genes or loci: *TP53*, *GSTM1* and the amylase locus.

**Learning objectives**
- **Navigate the browser:** Familiarize ourselves with basic functionality in the UCSC Genome Browser.
- **Read HPRC alignments:** Learn what the HPRC assemblies look like aligned to GRCh38.
- **Connect gaps to structural variants:** Look at a well-known gene and work out what the alignments and SV calls are showing.
- **See where GRCh38 falls short:** Explore a complex locus and think about what a single reference can and can't represent.

**Instructions:** [Part 1 Instructions (PDF)](instructions/NSGC26_Workshop_Hands_On_Part1_Instructions.pdf)

## 2. From Reference to Variant Calls with the Pangenome Viewer

**What you do:** Compare the sequencing reads mapped two ways: to the linear reference (GRCh38) and to a pangenome. You look at clinically relevant examples of both single nucleotide variants and structural variants where the choice of reference genome makese a difference.

**Learning objectives**
- **Spot mismapped reads:** Compare a pair of nearly identical genes and look for signs that reads have landed in the wrong one.
- **Find hidden deletions:** Look inside repetitive regions and see whether a known deletion shows up in the reads and the calls.
- **Put mapping quality in context:** Learn what mapping quality does and doesn't tell you about where a read belongs.
- **See what changes with a pangenome:** Compare the same reads on both references and note what a report would say differently.

**Instructions:** [Part 2 Instructions (PDF)](instructions/NSGC26_Workshop_Hands_On_Part2_Instructions.pdf)

---

## What you need

- A laptop with a recent web browser (Chrome, Edge, Firefox or Safari)
- An internet connection

## Repository contents

```
nsgc-2026/
├── instructions/   Step-by-step guides for both activities
└── resources/      Pangenome Viewer download (zip)
```
