#!/bin/bash

umi_tools \
extract \
--random-seed 1 \
--stdin \
inputs/293T_4kB_gel_S4_L003_R1_001.fastq.gz \
--bc-pattern \
NNNNNNNNNN \
--log \
eCLASHpilot.4kB_gel.umi.r1.fq.metrics \
--stdout \
eCLASHpilot.4kB_gel.umi.r1.fq

