umi_tools dedup \
--random-seed 1 \
-I inputs/Au4.reverse_mir_alignments.filtered.chimeric_candidates.STARAligned.outSo.bam \
--output-stats outputs/Au4.reverse_mir_alignments.filtered.chimeric_candidates.STARAligned.outSo \
-S outputs/Au4.reverse_mir_alignments.filtered.chimeric_candidates.STARAligned.outSo.rmDup.bam \
--method unique
