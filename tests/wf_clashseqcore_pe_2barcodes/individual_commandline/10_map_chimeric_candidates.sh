bowtie \
--best \
-e 35 \
-f \
-k 1 \
-l 8 \
-m 1 \
-n 1 \
-p 8 \
--strata \
hg19 \
barcode1_reverse_miR_alignments.chimeric_candidates.fa \
barcode1_chimeric_genome_alignments.tsv 2> barcode1_chimeric_genome_alignments.tsv.log
