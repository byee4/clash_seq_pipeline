module load umitools/1.0.0


umi_tools extract \
--random-seed 1 \
--bc-pattern NNNNNNNNNN \
--log gk.Au4.umi_extract_metrics \
--stdout outputs/gk.Au4.umi.r1.fq \
--stdin inputs/Au4_S4_L001_R1_001.fastq.gz

