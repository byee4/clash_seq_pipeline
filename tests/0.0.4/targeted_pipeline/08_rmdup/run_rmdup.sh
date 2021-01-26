umi_tools dedup \
--random-seed 1 \
-I inputs/gk.Au17.umi.r1.fq.genome-mappedSoSo.bam \
--output-stats outputs/gk.Au17.umi.r1.fq.genome-mappedSoSo \
-S outputs/gk.Au17.umi.r1.fq.genome-mappedSoSo.rmDup.bam \
--method unique

samtools sort -o outputs/gk.Au17.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam outputs/gk.Au17.umi.r1.fq.genome-mappedSoSo.rmDup.bam
samtools index outputs/gk.Au17.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam