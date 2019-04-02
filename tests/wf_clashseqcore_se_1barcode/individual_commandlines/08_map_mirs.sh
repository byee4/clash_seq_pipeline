bowtie \
-a \
-e 35 \
-f \
-l 8 \
-n 1 \
-p 8 \
reads_bowtie_index \
inputs/hsa_mature.T.fa \
reverse_miR_alignments.tsv 2> reverse_miR_alignments.tsv.log
