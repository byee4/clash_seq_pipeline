# bowtie \
# -p 8 \
# -e 35 \
# -f \
# -l 8 \
# -n 1 \
# -a \
# -y \
# hg19 \
# inputs/miRNA.chimeric_candidates_single.fa \
# outputs/chimeric_alignments_single.tsv

bowtie \
-v 3 \
-p 8 \
-f \
-a \
hg19 \
inputs/miRNA.chimeric_candidates_single.fa \
outputs/chimeric_alignments_single.tsv
