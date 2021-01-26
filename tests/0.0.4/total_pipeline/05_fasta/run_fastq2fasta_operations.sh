fastq-sort --id inputs/gk.Au4.umi.r1.fqTrTrTr.fq > outputs/gk.Au4.umi.r1.fqTrTrTr.fq.sorted.fq
seqtk seq -A outputs/gk.Au4.umi.r1.fqTrTrTr.fq.sorted.fq > outputs/gk.Au4.umi.r1.fqTrTrTr.fq.sorted.fa
fasta2collapse.pl outputs/gk.Au4.umi.r1.fqTrTrTr.fq.sorted.fa outputs/gk.Au4.umi.r1.fqTrTrTr.fq.sorted.collapsed.fa
