#!/bin/bash

umi_tools \
extract \
--random-seed 1 \
--stdin \
inputs/N2_CTL_IP_1_6_S13_L008_R1_001.fastq.gz \
--bc-pattern \
NNNNNNNNNN \
--log \
eCLASHpilot.EV199.umi.r1.log \
--stdout \
eCLASHpilot.EV199.umi.r1.fq

