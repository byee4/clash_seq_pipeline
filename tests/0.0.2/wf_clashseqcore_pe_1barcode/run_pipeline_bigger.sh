echo $(date +%x,%r) > START.bigger.txt;

./wf_clipseqcore_pe_1barcode_bigger.yaml > bigger_log.txt 2>&1

echo $(date +%x,%r) > FINISHED.bigger.txt;


