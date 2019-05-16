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

import collapse_bowtie_results as c


### Fixtures ###

curdir = os.path.dirname(__file__)

test1_tsv = os.path.join(
    curdir,
    'test_alignments/test1.tsv'
)
test2_tsv = os.path.join(
    curdir,
    'test_alignments/test2.tsv'
)
test3_tsv = os.path.join(
    curdir,
    'test_alignments/test3.tsv'
)

### Tests ###

def test_filter_stranded_alignments_1():
    """

    """
    bowtie_headers = [
        "mir", "strand", "ref_name", "offset0base", "qseq", 
        "qualities", "alt_alignments", "mutation_string"
    ]
    df = pd.read_csv(test1_tsv, sep='\t', names=bowtie_headers)
    df['mutation_num'] = df.apply(c.return_mismatch_number, axis=1)
    df['int_strand'] = df.apply(c.strand2int, axis=1)
    dx = c.filter_stranded_alignments(df)
    assert set(dx['strand']) == set(['+']) # only + strand survives
    assert dx.shape[0] == 5 # removing 3 out of 8 alignments due to strand

    
def test_filter_stranded_alignments_2():
    """

    """
    bowtie_headers = [
        "mir", "strand", "ref_name", "offset0base", "qseq", 
        "qualities", "alt_alignments", "mutation_string"
    ]
    df = pd.read_csv(test2_tsv, sep='\t', names=bowtie_headers)
    df['mutation_num'] = df.apply(c.return_mismatch_number, axis=1)
    df['int_strand'] = df.apply(c.strand2int, axis=1)
    dx = c.filter_stranded_alignments(df)
    assert set(dx['strand']) == set(['-']) # only - strand exists and thus should survive
    assert dx.shape[0] == 3 # removing 0 out of 3 alignments due to strand
    

def test_filter_stranded_alignments_3():
    """

    """
    bowtie_headers = [
        "mir", "strand", "ref_name", "offset0base", "qseq", 
        "qualities", "alt_alignments", "mutation_string"
    ]
    df = pd.read_csv(test3_tsv, sep='\t', names=bowtie_headers)
    df['mutation_num'] = df.apply(c.return_mismatch_number, axis=1)
    df['int_strand'] = df.apply(c.strand2int, axis=1)
    dx = c.filter_stranded_alignments(df)
    assert set(dx['strand']) == set(['-','+']) # both + and - strand should be here
    assert dx.shape[0] == 2 # removing 2 out of 4 alignments due to strand
    
    
def test_filter_mismatched_alignments_1():
    """

    """
    bowtie_headers = [
        "mir", "strand", "ref_name", "offset0base", "qseq", 
        "qualities", "alt_alignments", "mutation_string"
    ]
    df = pd.read_csv(test1_tsv, sep='\t', names=bowtie_headers)
    df['mutation_num'] = df.apply(c.return_mismatch_number, axis=1)
    df['int_strand'] = df.apply(c.strand2int, axis=1)
    dx = c.filter_mismatched_alignments(df)
    assert dx.shape[0] == 5 # removing 3 out of 8 alignments due to strand
    

def test_filter_mismatched_alignments_2():
    """

    """
    bowtie_headers = [
        "mir", "strand", "ref_name", "offset0base", "qseq", 
        "qualities", "alt_alignments", "mutation_string"
    ]
    df = pd.read_csv(test2_tsv, sep='\t', names=bowtie_headers)
    df['mutation_num'] = df.apply(c.return_mismatch_number, axis=1)
    df['int_strand'] = df.apply(c.strand2int, axis=1)
    dx = c.filter_mismatched_alignments(df)
    assert dx.shape[0] == 2 # removing 1 out of 3 alignments due to mismatches
    

def test_collapse_bowtie_output_1():
    """

    """
    bowtie_headers = [
        "mir", "strand", "ref_name", "offset0base", "qseq", 
        "qualities", "alt_alignments", "mutation_string"
    ]
    dy = c.collapse_bowtie_output(test3_tsv)
    assert dy.shape[0] == 2 # removing 1 out of 3 alignments due to strand AND mismatches