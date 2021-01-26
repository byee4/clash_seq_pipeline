module load cutadapt

cutadapt \
-O 1 \
-f fastq \
--match-read-wildcards \
--times 1 \
-e 0.1 \
-m 18 \
--quality-cutoff 6 \
-o outputs/gk.Au17.umi.r1.fqTr.fq \
-a AGATCGGAAGAGCAC \
-a GATCGGAAGAGCACA \
-a ATCGGAAGAGCACAC \
-a TCGGAAGAGCACACG \
-a CGGAAGAGCACACGT \
-a GGAAGAGCACACGTC \
-a GAAGAGCACACGTCT \
-a AAGAGCACACGTCTG \
-a AGAGCACACGTCTGA \
-a GAGCACACGTCTGAA \
-a AGCACACGTCTGAAC \
-a GCACACGTCTGAACT \
-a CACACGTCTGAACTC \
-a ACACGTCTGAACTCC \
-a CACGTCTGAACTCCA \
-a ACGTCTGAACTCCAG \
-a CGTCTGAACTCCAGT \
-a GTCTGAACTCCAGTC \
-a TCTGAACTCCAGTCA \
-a CTGAACTCCAGTCAC \
inputs/gk.Au17.umi.r1.fq.gz