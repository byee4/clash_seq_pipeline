bowtie-build \
--offrate 2 \
--threads 8 \
inputs/gk.Au4.umi.r1.fqTrTrTr.fq.sorted.collapsed.fa \
bowtie_index

bowtie \
-a \
-e 35 \
-f \
-l 8 \
-n 1 \
-p 8 \
bowtie_index \
inputs/mature.hsa.T.fa \
Au4.reverse_mir_alignments.tsv 2> Au4.reverse_mir_alignments.tsv.log
