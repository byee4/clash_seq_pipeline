#!/usr/bin/env bash

module load eclash/0.0.4

STAR \
    --alignEndsType \
    EndToEnd \
    --genomeDir \
    inputs/star_2_7_homo_sapiens_repbase_fixed_v2 \
    --genomeLoad \
    NoSharedMemory \
    --outBAMcompression \
    10 \
    --outFileNamePrefix \
    outputs/gk.Au17.umi.r1.fq.repeat-mapped \
    --outFilterMultimapNmax \
    30 \
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
    inputs/gk.Au17.umi.r1.fqTrTrTr.fq.primer.fq \
    --runMode \
    alignReads \
    --runThreadN \
    8

mv outputs/gk.Au17.umi.r1.fq.repeat-mappedAligned.out.bam outputs/gk.Au17.umi.r1.fq.repeat-mapped.bam
