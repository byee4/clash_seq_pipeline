#!/usr/bin/env bash

module load eclash/0.0.4

filter_primers.py \
--read1 inputs/gk.Au17.umi.r1.fqTrTrTr.fq.gz \
--primer CAGTGCAATGTTAAAAGGGCAT \
--output_file outputs/gk.Au17.umi.r1.fqTrTrTr.fq.primer.fq
