#!/usr/bin/env bash

module load eclash/0.0.4

targeted_miR_umi.py \
--read1 inputs/Au17_S17_L001_R1_001.fastq.gz \
--read2 inputs/Au17_S17_L001_R2_001.fastq.gz \
--output_file outputs/gk.Au17.umi.r1.fq.gz
