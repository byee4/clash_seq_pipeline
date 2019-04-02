#!/usr/bin/env cwltool

### Workflow for handling reads containing one barcode ###

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  
inputs:
  dataset:
    type: string

  # TODO: remove, we don't use it here.
  species:
    type: string

  ## end eCLIP-specific params ##

  read:
    type:
      type: record
      fields:
        read1:
          type: File
        adapters:
          type: File
        name:
          type: string

  mirna_fasta:
    type: File
  bowtie_genome_prefix:
    type: string
  bowtie_genome_directory:
    type: Directory

  b1_read_idx_name:
    type: string
    default: "reads_bowtie_index"
  b1_reverse_aligned_tsv:
    type: string
    default: "reverse_miR_alignments.tsv"
  b1_genome_aligned_tsv:
    type: string
    default: "chimeric_genome_alignments.tsv"
  b1_genome_aligned_e2e_tsv:
    type: string
    default: "chimeric_genome_alignments_e2e.tsv"
    
outputs:

  b1_demuxed_fastq_r1:
    type: File
    outputSource: demultiplex/A_output_demuxed_read1

  b1_trimx1_fastq:
    type: File[]
    outputSource: b1_trim_and_map/X_output_trim_first
  b1_trimx1_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_first_metrics
  b1_trimx2_fastq:
    type: File[]
    outputSource: b1_trim_and_map/X_output_trim_again
  b1_trimx2_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_again_metrics
    
  ### REVERSE MAPPING OUTPUTS ###

  b1_read1_fasta:
    type: File
    outputSource: b1_trim_and_map/read1_fasta
  b1_collapsed_read1_fasta:
    type: File
    outputSource: b1_trim_and_map/collapsed_read1_fasta
  b1_read_idx:
    type: Directory
    outputSource: b1_trim_and_map/read_idx
  b1_mir_alignments:
    type: File
    outputSource: b1_trim_and_map/mir_alignments
  b1_chimeric_alignment_candidates:
    type: File
    outputSource: b1_trim_and_map/chimeric_alignment_candidates
  b1_chimeric_alignment_metrics:
    type: File
    outputSource: b1_trim_and_map/chimeric_alignment_metrics
  b1_genome_alignments:
    type: File
    outputSource: b1_trim_and_map/genome_alignments
  b1_genome_alignments_e2e:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_e2e
   

steps:

###########################################################################
# Upstream
###########################################################################

  demultiplex:
    run: wf_demultiplex_se.cwl
    in:
      dataset: dataset
      read: read
    out: [
      A_output_demuxed_read1,
      read_name,
      dataset_name
    ]

  b1_trim_and_map:
    run: wf_clashseq_trim_and_map_se.cwl
    in:
      trimfirst_overlap_length:
        default: "1"
      trimagain_overlap_length:
        default: "5"
      a_adapters: 
        source: read
        valueFrom: |
          ${
            return self.adapters;
          }
      read1: demultiplex/A_output_demuxed_read1
      mirna_fasta: mirna_fasta
      bowtie_genome_prefix: bowtie_genome_prefix
      bowtie_genome_directory: bowtie_genome_directory
      read_idx_name: b1_read_idx_name
      reverse_aligned_tsv: b1_reverse_aligned_tsv
      genome_aligned_tsv: b1_genome_aligned_tsv
      genome_aligned_tsv_e2e: b1_genome_aligned_e2e_tsv
      read_name: demultiplex/read_name
      dataset_name: demultiplex/dataset_name
      
    out: [
      X_output_trim_first,
      X_output_trim_first_metrics,
      X_output_trim_again,
      X_output_trim_again_metrics,
      read1_fasta,
      collapsed_read1_fasta,
      read_idx,
      mir_alignments,
      chimeric_alignment_candidates,
      chimeric_alignment_metrics,
      genome_alignments,
      genome_alignments_e2e
    ]


###########################################################################
# Downstream (candidate for merging with main pipeline)
###########################################################################
