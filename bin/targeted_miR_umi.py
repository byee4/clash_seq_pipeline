#!/usr/bin/env python

# adds a number of bases to both ends of a fasta file

import argparse
import os
from Bio import SeqIO

def add_umi_to_r1(read1, read2, output_dir):
    #r1 = gzip.open(read1, 'rt')
    r1 = open(read1, 'r')
    with open(os.path.join(output_dir, os.path.basename(read1).replace('.fastq','.umi.fastq')), 'w') as r1_umi:
        # with gzip.open(read2, 'rt') as r2:
        with open(read2, 'r') as r2:
            for record in SeqIO.parse(r2, "fastq"):

                # print(record.id, r1.readline().split(' ')[0][1:])
                r1_header = r1.readline()
                r1_sequence = r1.readline()
                r1_next = r1.readline()
                r1_quality = r1.readline()


                r1_header_id, r1_header_desc = r1_header.split(' ')

                r1_header_id_no_at = r1_header_id[1:] # remove the "@" prefix
                assert record.id == r1_header_id_no_at # make sure that the read ids for r1 and r2 align to each other
                umi_sequence = str(record.seq)[:10]

                r1_umi.write(r1_header_id + "_{} ".format(umi_sequence) + r1_header_desc)
                r1_umi.write(r1_sequence)
                r1_umi.write(r1_next)
                r1_umi.write(r1_quality)
                
def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--read1",
        required=True,
    )
    parser.add_argument(
        "--read2",
        required=True,
    )
    parser.add_argument(
        "--output_dir",
        required=True,
    )

    # Process arguments
    args = parser.parse_args()
    read1 = args.read1
    read2 = args.read2
    output_dir = args.output_dir
    
    # main func
    add_umi_to_r1(
        read1=read1,
        read2=read2,
        output_dir=output_dir
    )

if __name__ == "__main__":
    main()
