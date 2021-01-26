#!/usr/bin/env bash

module load eclash/0.0.4;

collapse_bowtie_results.py \
--bowtie_align inputs/Au4.reverse_mir_alignments.tsv \
--out_file outputs/Au4.reverse_mir_alignments.filtered.tsv

find_candidate_chimeric_seqs_from_mir_alignments.py \
--bowtie_align outputs/Au4.reverse_mir_alignments.filtered.tsv \
--fa_file inputs/gk.Au4.umi.r1.fqTrTrTr.fq.sorted.fa \
--out_file outputs/Au4.reverse_mir_alignments.filtered.chimeric_candidates.fa \
--metrics_file outputs/Au4.reverse_mir_alignments.filtered.metrics