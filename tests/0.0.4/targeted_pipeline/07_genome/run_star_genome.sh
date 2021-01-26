#!/usr/bin/env bash

module load eclash/0.0.4

STAR \
    --alignEndsType \
    EndToEnd \
    --genomeDir \
    inputs/star_2_7_6a_gencode19_sjdb \
    --genomeLoad \
    NoSharedMemory \
    --outBAMcompression \
    10 \
    --outFileNamePrefix \
    outputs/gk.Au17.umi.r1.fq.genome-mapped \
    --outFilterMultimapNmax \
    1 \
    --outFilterMultimapScoreRange \
    1 \
    --outFilterScoreMin \
    10 \
    --outFilterType \
    BySJout \
    --outReadsUnmapped \
    Fastx \
    --outSAMattrRGline \
    ID:foo \
    --outSAMattributes \
    All \
    --outSAMmode \
    Full \
    --outSAMtype \
    BAM \
    Unsorted \
    --outSAMunmapped \
    Within \
    --outStd \
    Log \
    --readFilesIn \
    inputs/gk.Au17.umi.r1.fq.repeat-mappedUnmapped.out.mate1 \
    --runMode \
    alignReads \
    --runThreadN \
    8

samtools sort -n -o outputs/gk.Au17.umi.r1.fq.genome-mappedSo.bam outputs/gk.Au17.umi.r1.fq.genome-mappedAligned.out.bam 
samtools sort -o outputs/gk.Au17.umi.r1.fq.genome-mappedSoSo.bam outputs/gk.Au17.umi.r1.fq.genome-mappedSo.bam
samtools index outputs/gk.Au17.umi.r1.fq.genome-mappedSoSo.bam
