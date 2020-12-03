# clash_seq_pipeline
Processing pipeline as described in Moore et al. 2015

## Steps:
- Call peaks 
- 'reverse' map mature miRs against sample libraries with Bowtie (-n 1 -l 8 -e 35 -k -1)
- Reads mapping to more than one miR are 'family mapped' and are collapsed into single hit.
- Chimeric sequences (upstream and downstream) are extracted, identified as 
- Chimeric sequences are filtered for a min length of 18 and mapped to genome
