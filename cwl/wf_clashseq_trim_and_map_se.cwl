#!/usr/bin/env cwltool

### space to remind me of what the metadata runner is ###

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement

#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:

  trimfirst_overlap_length:
    type: string
  trimagain_overlap_length:
    type: string
  # g_adapters:
  #   type: File
  # g_adapters_default:
  #   type: File
  a_adapters:
    type: File
  # a_adapters_default:
  #   type: File
  # A_adapters:
  #   type: File
  read1:
    type: File
  read_name:
    type: string
  dataset_name:
    type: string
    
  mirna_fasta:
    type: File
  bowtie_genome_prefix:
    type: string
  bowtie_genome_directory:
    type: Directory

  read_idx_name:
    type: string
  reverse_aligned_tsv:
    type: string
  genome_aligned_tsv:
    type: string
    doc: "seed based alignments (l=8, n=2)"
  genome_aligned_tsv_e2e:
    type: string
    doc: "end-to-end alignments (v=3)"
    
  ## Default trim params ##
  sort_names:
    type: boolean
    default: true
  trim_times:
    type: string
    default: "1"
  trim_error_rate:
    type: string
    default: "0.1"

  ## Bowtie params ##

  n:
    type: int
    default: 1
  l:
    type: int
    default: 8
  e:
    type: int
    default: 35
  v:
    type: int
    default: 3

outputs:

  X_output_trim_first:
    type: File[]
    outputSource: step_gzip_sort_X_trim/gzipped
  X_output_trim_first_metrics:
    type: File
    outputSource: X_trim/output_trim_report

  X_output_trim_again:
    type: File[]
    outputSource: step_gzip_sort_X_trim_again/gzipped
  X_output_trim_again_metrics:
    type: File
    outputSource: X_trim_again/output_trim_report

  read1_fasta:
    type: File
    outputSource: step_fastq_to_fasta/output_fasta_file
  
  collapsed_read1_fasta:
    type: File
    outputSource: step_fasta2collapse/collapsed_file

  read_idx:
    type: Directory
    outputSource: step_file2directory/out

  mir_alignments:
    type: File
    outputSource: step_map_mirs/output

  chimeric_alignment_candidates:
    type: File
    outputSource: step_find_chimeric_candidates/chimeric_candidates_file

  chimeric_alignment_metrics:
    type: File
    outputSource: step_find_chimeric_candidates/metrics_file

  genome_alignments:
    type: File
    outputSource: step_map_chimeric_seqs_to_genome/output
  
  genome_alignments_e2e:
    type: File
    outputSource: step_map_chimeric_seqs_to_genome_e2e/output

steps:

###########################################################################
# Parse adapter files to array inputs
###########################################################################

  get_a_adapters:
    run: file2stringArray.cwl
    in:
      file: a_adapters
    out:
      [output]

###########################################################################
# Trim
###########################################################################

  X_trim:
    run: trim_se.cwl
    in:
      input_trim: 
        source: read1
        valueFrom: ${ return [ self ]; }
      input_trim_overlap_length: trimfirst_overlap_length
      input_trim_a_adapters: get_a_adapters/output
      times: trim_times
      error_rate: trim_error_rate
    out: [output_trim, output_trim_report]
  
  step_gzip_sort_X_trim:
    run: gzip.cwl
    scatter: input
    in:
      input: X_trim/output_trim
    out:
      - gzipped
      
  X_trim_again:
    run: trim_se.cwl
    in:
      input_trim: X_trim/output_trim
      input_trim_overlap_length: trimagain_overlap_length
      input_trim_a_adapters: get_a_adapters/output
      times: trim_times
      error_rate: trim_error_rate
    out: [output_trim, output_trim_report]
  
  A_sort_trimmed_fastq:
    run: fastqsort.cwl
    scatter: input_fastqsort_fastq
    in:
      input_fastqsort_fastq: X_trim_again/output_trim
    out:
      [output_fastqsort_sortedfastq]
      
  step_gzip_sort_X_trim_again:
    run: gzip.cwl
    scatter: input
    in:
      input: A_sort_trimmed_fastq/output_fastqsort_sortedfastq
    out:
      - gzipped
      
###########################################################################
# Collapse reads and reverse-map miRs
###########################################################################

  step_fastq_to_fasta:
    run: fastq2fasta.cwl
    in:
      fastq_file:
        source: A_sort_trimmed_fastq/output_fastqsort_sortedfastq
        valueFrom: |
          ${
            return self[0];
          }
    out:
      - output_fasta_file

  step_fasta2collapse:
    run: fasta2collapse.cwl
    in:
      input_file: step_fastq_to_fasta/output_fasta_file
    out:
      - collapsed_file

  step_index_reads:
    run: bowtie-build.cwl
    in:
      fasta_file: step_fasta2collapse/collapsed_file
      index_base_name: read_idx_name
    out:
      - indices

  step_file2directory:
    run: file2directory.cwl
    in:
      idx_files: step_index_reads/indices
      outdir: read_idx_name
    out:
      - out

  step_map_mirs:
    run: bowtie-mir.cwl
    in:
      n: n
      l: l
      e: e
      ebwt: read_idx_name
      bowtie_db: step_file2directory/out
      filelist:
        source: mirna_fasta
        valueFrom: ${return [ self ];}
      filename: reverse_aligned_tsv
    out:
      - output
      - output_bowtie_log

  step_find_chimeric_candidates:
    run: find_candidate_chimeric_seqs_from_mir_alignments.cwl
    in:
      bowtie_align: step_map_mirs/output
      fa_file: step_fastq_to_fasta/output_fasta_file
    out:
      - chimeric_candidates_file
      - metrics_file

  step_map_chimeric_seqs_to_genome:
    run: bowtie-genome.cwl
    in:
      n: n
      l: l
      e: e
      ebwt: bowtie_genome_prefix
      bowtie_db: bowtie_genome_directory
      filelist:
        source: step_find_chimeric_candidates/chimeric_candidates_file
        valueFrom: ${return [ self ];}
      filename: genome_aligned_tsv
    out:
      - output
      - output_bowtie_log
  
  step_map_chimeric_seqs_to_genome_e2e:
    run: bowtie-genome.cwl
    in:
      v: v
      ebwt: bowtie_genome_prefix
      bowtie_db: bowtie_genome_directory
      filelist:
        source: step_find_chimeric_candidates/chimeric_candidates_file
        valueFrom: ${return [ self ];}
      filename: genome_aligned_tsv_e2e
    out:
      - output
      - output_bowtie_log

doc: |
  This workflow takes in appropriate trimming params and demultiplexed reads,
  and performs the following steps in order: trimx1, trimx2, fastq-sort, filter repeat elements, fastq-sort, genomic mapping, sort alignment, index alignment, namesort, PCR dedup, sort alignment, index alignment
