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


###############################################################################
##                            Download Verkko Trio Folder                    ##
###############################################################################

mkdir -p /nesi/nobackup/nesi02659/LRA/resources/assemblies/verkko/full/trio/

/home/juklucas/bin/aws \
    s3 --no-sign-request cp \
    s3://human-pangenomics/submissions/53FEE631-4264-4627-8FB6-09D7364F4D3B--ASM-COMP/HG002/assemblies/verkko_1.3.1/trio/supporting_files/assembly_verkko_v1.3_trio.tar \
    /nesi/nobackup/nesi02659/LRA/resources/assemblies/verkko/full/trio/