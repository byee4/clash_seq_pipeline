#!/bin/bash

eclipdemux \
--dataset SA_OE_WT \
--newname SA_OE_WT_demuxed \
--metrics SA_OE_WT.metrics \
--fastq_1 SA_OE_IP_S24_L004_R1_001.fastq.gz \
--fastq_2 SA_OE_IP_S24_L004_R2_001.fastq.gz \
--expectedbarcodeida X1A \
--expectedbarcodeidb X1B \
--barcodesfile yeolabbarcodes_20170101.fasta \
--length 10 \
--max_hamming_distance 1
