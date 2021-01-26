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
    outputs/Au4.reverse_mir_alignments.filtered.chimeric_candidates.STAR \
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
    inputs/Au4.reverse_mir_alignments.filtered.chimeric_candidates.fa \
    --runMode \
    alignReads \
    --runThreadN \
    8

samtools sort -o outputs/Au4.reverse_mir_alignments.filtered.chimeric_candidates.STARAligned.outSo.bam outputs/Au4.reverse_mir_alignments.filtered.chimeric_candidates.STARAligned.out.bam
samtools index outputs/Au4.reverse_mir_alignments.filtered.chimeric_candidates.STARAligned.outSo.bam 
