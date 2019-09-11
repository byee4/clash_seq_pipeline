echo $(date +%x,%r) > START.txt;

./wf_clipseqcore_pe_1barcode.yaml > full_log.txt 2>&1

echo $(date +%x,%r) > FINISHED.txt;


