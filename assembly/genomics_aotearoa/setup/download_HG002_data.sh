###############################################################################
##                                   Setup                                   ##
###############################################################################

## log in to NeSi
cd ~

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip

## Install to my home directory
mkdir bin
./aws/install -i /home/juklucas/bin/aws-cli -b /home/juklucas/bin

## Test install
/home/juklucas/bin/aws --version


###############################################################################
##                           Download PacBio Data                            ##
###############################################################################

mkdir /nesi/nobackup/nesi02659/LRA/resources/deepconsensus/

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/C67D4C08-3C8F-4ADD-9D87-E282D2CD70D6--DEEPCONSENSUS/HG002/Q20/m64011_190830_220126.Q20.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/deepconsensus/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/C67D4C08-3C8F-4ADD-9D87-E282D2CD70D6--DEEPCONSENSUS/HG002/Q20/m64011_190901_095311.Q20.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/deepconsensus/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/C67D4C08-3C8F-4ADD-9D87-E282D2CD70D6--DEEPCONSENSUS/HG002/Q20/m64012_190920_173625.Q20.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/deepconsensus/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/C67D4C08-3C8F-4ADD-9D87-E282D2CD70D6--DEEPCONSENSUS/HG002/Q20/m64012_190921_234837.Q20.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/deepconsensus/ &


###############################################################################
##                            Download ONT Data                              ##
###############################################################################

mkdir /nesi/nobackup/nesi02659/LRA/resources/ont_ul/ 

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/NHGRI_UCSC_panel/HG002/nanopore/ultra-long/03_08_22_R941_HG002_1_Guppy_6.1.2_5mc_cg_prom_sup.bam \
    /nesi/nobackup/nesi02659/LRA/resources/ont_ul/

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/NHGRI_UCSC_panel/HG002/nanopore/ultra-long/03_08_22_R941_HG002_2_Guppy_6.1.2_5mc_cg_prom_sup.bam \
    /nesi/nobackup/nesi02659/LRA/resources/ont_ul/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/NHGRI_UCSC_panel/HG002/nanopore/ultra-long/03_08_22_R941_HG002_3_Guppy_6.1.2_5mc_cg_prom_sup.bam \
    /nesi/nobackup/nesi02659/LRA/resources/ont_ul/ &


###############################################################################
##                            Download Meryl Hapmer DBs                      ##
###############################################################################

mkdir /nesi/nobackup/nesi02659/LRA/resources/meryl

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/T2T/HG002/qc/maternal_compress.k30.hapmer.meryl.tar.gz \
    /nesi/nobackup/nesi02659/LRA/resources/meryl/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/T2T/HG002/qc/paternal_compress.k30.hapmer.meryl.tar.gz \
    /nesi/nobackup/nesi02659/LRA/resources/meryl/ &

## extract and cleanup
tar xvf \
    /nesi/nobackup/nesi02659/LRA/resources/meryl/maternal_compress.k30.hapmer.meryl.tar.gz \
    --directory /nesi/nobackup/nesi02659/LRA/resources/meryl/

tar xvf \
    /nesi/nobackup/nesi02659/LRA/resources/meryl/paternal_compress.k30.hapmer.meryl.tar.gz \
    --directory /nesi/nobackup/nesi02659/LRA/resources/meryl/

rm /nesi/nobackup/nesi02659/LRA/resources/meryl/*tar.gz

###############################################################################
##                               Download Ilmn Data                           ##
###############################################################################

mkdir -p /nesi/nobackup/nesi02659/LRA/resources/ilmn/pat 
mkdir -p /nesi/nobackup/nesi02659/LRA/resources/ilmn/mat

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/Illumina/parents/HG003/HG003_HiSeq30x_subsampled_R1.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/ilmn/pat/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/Illumina/parents/HG003/HG003_HiSeq30x_subsampled_R2.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/ilmn/pat/ &


/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/Illumina/parents/HG004/HG004_HiSeq30x_subsampled_R1.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/ilmn/mat/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/Illumina/parents/HG004/HG004_HiSeq30x_subsampled_R2.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/ilmn/mat/ &


###############################################################################
##                               Download HiC Data                           ##
###############################################################################

mkdir -p /nesi/nobackup/nesi02659/LRA/resources/hic

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/hic/downsampled/HG002.HiC_1_S1_R1_001.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/hic/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/hic/downsampled/HG002.HiC_1_S2_R1_001.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/hic/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/hic/downsampled/HG002.HiC_1_S3_R1_001.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/hic/ &    

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/hic/downsampled/HG002.HiC_1_S1_R2_001.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/hic/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/hic/downsampled/HG002.HiC_1_S2_R2_001.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/hic/ &

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/working/HPRC_PLUS/HG002/raw_data/hic/downsampled/HG002.HiC_1_S3_R2_001.fastq.gz \
    /nesi/nobackup/nesi02659/LRA/resources/hic/ &



###############################################################################
##                                 Download Yaks                             ##
###############################################################################

mkdir /nesi/nobackup/nesi02659/LRA/resources/yak

## sample
/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/backup/GA/HG002/yak/HG002.yak \
    /nesi/nobackup/nesi02659/LRA/resources/yak/

## mat
/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/6040D518-FE32-4CEB-B55C-504A05E4D662--HG002_PARENTAL_YAKS/HG002_PARENTS_FULL/mat.HG004.yak \
    /nesi/nobackup/nesi02659/LRA/resources/yak/ &

## pat
/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/6040D518-FE32-4CEB-B55C-504A05E4D662--HG002_PARENTAL_YAKS/HG002_PARENTS_FULL/pat.HG003.yak \
    /nesi/nobackup/nesi02659/LRA/resources/yak/ &


###############################################################################
##                            Download Verkko Trio Folder                    ##
###############################################################################

mkdir -p /nesi/nobackup/nesi02659/LRA/resources/assemblies/verkko/full/trio/

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/53FEE631-4264-4627-8FB6-09D7364F4D3B--ASM-COMP/HG002/assemblies/verkko_1.3.1/trio/supporting_files/assembly_verkko_v1.3_trio.tar \
    /nesi/nobackup/nesi02659/LRA/resources/assemblies/verkko/full/trio/

## extract
tar xvf \
    /nesi/nobackup/nesi02659/LRA/resources/assemblies/verkko/full/trio/assembly_verkko_v1.3_trio.tar \
    --directory /nesi/nobackup/nesi02659/LRA/resources/assemblies/verkko/full/trio/


###############################################################################
##                            Download Verkko GFAse Run                      ##
###############################################################################

mkdir -p /nesi/nobackup/nesi02659/LRA/resources/assemblies/verkko/full/hic

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/53FEE631-4264-4627-8FB6-09D7364F4D3B--ASM-COMP/HG002/assemblies/verkko_1.3.1/gfase/HG002_verkko_gfase_diploid.fasta.gz \
    /nesi/nobackup/nesi02659/LRA/resources/assemblies/verkko/full/hic    

###############################################################################
##                            Download Hifiasm Asms                          ##
###############################################################################

mkdir -p /nesi/nobackup/nesi02659/LRA/resources/assemblies/hifiasm/full/trio

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/53FEE631-4264-4627-8FB6-09D7364F4D3B--ASM-COMP/HG002/assemblies/hifiasm_v0.19.5/trio/HG002.mat.fa.gz \
    /nesi/nobackup/nesi02659/LRA/resources/assemblies/hifiasm/full/trio/    

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/53FEE631-4264-4627-8FB6-09D7364F4D3B--ASM-COMP/HG002/assemblies/hifiasm_v0.19.5/trio/HG002.pat.fa.gz \
    /nesi/nobackup/nesi02659/LRA/resources/assemblies/hifiasm/full/trio/

mkdir -p /nesi/nobackup/nesi02659/LRA/resources/assemblies/hifiasm/full/hic

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/53FEE631-4264-4627-8FB6-09D7364F4D3B--ASM-COMP/HG002/assemblies/hifiasm_v0.19.5/hic/HG002.hap1.fa.gz \
    /nesi/nobackup/nesi02659/LRA/resources/assemblies/hifiasm/full/hic/

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/53FEE631-4264-4627-8FB6-09D7364F4D3B--ASM-COMP/HG002/assemblies/hifiasm_v0.19.5/hic/HG002.hap2.fa.gz \
    /nesi/nobackup/nesi02659/LRA/resources/assemblies/hifiasm/full/hic/

###############################################################################
##                          Download CHM13 & annotation data                 ##
###############################################################################

mkdir -p /nesi/nobackup/nesi02659/LRA/resources/chm13/
curl "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/GCF_009914755.1_T2T-CHM13v2.0_genomic.gff.gz" -o "/nesi/nobackup/nesi02659/LRA/resources/chm13/CHM13-T2T.gff.gz"
curl "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/GCF_009914755.1_T2T-CHM13v2.0_cds_from_genomic.fna.gz" -o "/nesi/nobackup/nesi02659/LRA/resources/chm13/CHM13-T2T.cds.fasta.gz"

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/T2T/CHM13/assemblies/chm13v2.0.fa \
    /nesi/nobackup/nesi02659/LRA/resources/chm13/
