#!/usr/env python

import os
import pandas as pd
import pybedtools
import pytest
import sys
import pysam

sys.path.append(
    os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir))
)

import find_candidate_chimeric_seqs_from_mir_alignments as c


### Fixtures ###

curdir = os.path.dirname(__file__)

test_sam = os.path.join(
    curdir,
    'test_alignments/test.sam'
)


### Tests ###

@pytest.mark.parametrize(
    "test_string, trimmed_string, leading_n_count",
    [
        ("NNNNNTTCCTATACAGTCTACTGTCTTTCTTNNNNNN", "TTCCTATACAGTCTACTGTCTTTCTT", 5),
        ("NNNNNTNNNTCCTATACAGTCTACTTTTCTTNNNNNN", "TNNNTCCTATACAGTCTACTTTTCTT", 5),
        ("NNNNNNNNNNN", "", 11),
        ("N", "", 1),
        ("", "", 0)
    ]
)
def test_trim_n_and_return_leading_offset(test_string, trimmed_string, leading_n_count):
    """

    """
    trimmed, n = c.trim_n_and_return_leading_offset(test_string)
    assert trimmed == trimmed_string
    assert n == leading_n_count

@pytest.mark.parametrize(
    "sam_file, expected_ref_seq, expected_mir, expected_strand",
    [
        (os.path.join(curdir, "test_alignments/test1.sam"), "TAGCTTATCAGACTGATGTTGA", "hsa-miR-21-5p", "+"),
        (os.path.join(curdir, "test_alignments/test2.sam"), "TTGGGATGGTAGGACCCGAGGGG", "hsa-miR-6728-5p", "+"),
    ]
)
def test_get_reference_seq_from_sam_alignedsegment(sam_file, expected_ref_seq, expected_mir, expected_strand):
    samfile = pysam.AlignmentFile(sam_file, "r")
    for read in samfile:
        strand = '-' if read.is_reverse else '+'
        
        ref_name, ref_seq, strand, mir = c.get_reference_seq_from_sam_alignedsegment(read)
        assert mir == expected_mir
        assert ref_seq == expected_ref_seq
        assert strand == expected_strand