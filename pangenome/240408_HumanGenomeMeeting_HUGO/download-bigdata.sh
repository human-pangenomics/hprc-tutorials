## script to download large files used in the PGGB part of the workshop
## will download files in a 'bigdata' folder
## it requires some dependencies (odgi, samtools, etc) that are included in the quay.io/jmonlong/hprc-hugo2024-jupyterhub image

mkdir -p bigdata
cd bigdata

wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/pggb/chroms/chrY.hprc-v1.0-pggb.gfa.gz
gunzip chrY.hprc-v1.0-pggb.gfa.gz
# extract all sequences in FASTA format with ODGI
odgi paths -i chrY.hprc-v1.0-pggb.gfa -f -t 8 -P > chrY.hprc-v1.0-pggb.gfa.fa
# index the FASTA
samtools faidx chrY.hprc-v1.0-pggb.gfa.fa
# We select the two references CHM13, GRCH38, and the 2 haplotypes of the HG01978 diploid sample:    
grep "chm13\|grch38\|HG01978" chrY.hprc-v1.0-pggb.gfa.fa.fai | cut -f 1 > chrY.pan4.txt
# fetch the sequences of the desired haplotypes
samtools faidx chrY.hprc-v1.0-pggb.gfa.fa -r chrY.pan4.txt > chrY.hprc.pan4.fa
# zip it
bgzip chrY.hprc.pan4.fa
# index the FASTA
samtools faidx chrY.hprc.pan4.fa.gz
rm chrY.hprc-v1.0-pggb.gfa chrY.hprc-v1.0-pggb.gfa.fa* chrY.pan4.txt

wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_11_16_pggb_wgg.88/chroms/chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz
gunzip chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz
odgi build -g chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa -o chr6.pan.og -t 8 -P
rm chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa

wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chrom.sizes
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz
zgrep 'gene_id "C4A"\|gene_id "C4B"' hg38.ncbiRefSeq.gtf.gz | awk '$1 == "chr6"' | cut -f 1,4,5 | bedtools sort | bedtools merge -d 15000 | bedtools slop -l 10000 -r 20000 -g hg38.chrom.sizes | sed 's/chr6/grch38#chr6/g' > hg38.ncbiRefSeq.C4.coordinates.bed
rm hg38.chrom.sizes hg38.ncbiRefSeq.gtf.gz

wget https://zenodo.org/record/7933393/files/primates14.chr6.fa.gz.667b9b6.c2fac19.ee137be.smooth.final.gfa.zst
zstd -d primates14.chr6.fa.gz.667b9b6.c2fac19.ee137be.smooth.final.gfa.zst
odgi build -g primates14.chr6.fa.gz.667b9b6.c2fac19.ee137be.smooth.final.gfa -o primates14.chr6.fa.gz.667b9b6.c2fac19.ee137be.smooth.final.og -t 8 -P
rm primates14.chr6.fa.gz.667b9b6.c2fac19.ee137be.smooth.final.gfa primates14.chr6.fa.gz.667b9b6.c2fac19.ee137be.smooth.final.gfa.zst

wget -c https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/pggb/chroms/chrM.hprc-v1.0-pggb.gfa.gz
gunzip chrM.hprc-v1.0-pggb.gfa.gz
mv chrM.hprc-v1.0-pggb.gfa chrM.gfa
wget -c https://zenodo.org/record/7937947/files/ecoli50.gfa.zst
zstd -d ecoli50.gfa.zst
