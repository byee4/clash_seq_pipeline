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

  dataset_name:
    type: string
  # species:
  #   type: string

  ## end eCLIP-specific params ##
  
  samples:
    type:
      type: array
      items:
        type: record
        fields:
          read1:
            type: File
          name:
            type: string
          adapters:
            type: File
  
  # samples:
  #   type:
  #     type: array
  #     items:
  #       type: array
  #       items:
  #         type: record
  #         fields:
  #           read1:
  #             type: File
  #           name:
  #             type: string
  #           adapters:
  #             type: File
              
  # mirna_fasta:
  #   type: File
  # bowtie_genome_prefix:
  #   type: string
  # bowtie_genome_directory:
  #   type: Directory
  
  # speciesGenomeDir:
  #   type: Directory
  # chrom_sizes:
  #   type: File
  # b1_read_idx_name:
  #   type: string
  #   default: "reads_bowtie_index"
  # b1_reverse_aligned_tsv:
  #   type: string
  #   default: "reverse_miR_alignments.tsv"
  # b1_genome_aligned_sam:
  #   type: string
  #   default: "chimeric_genome_alignments.sam"
    
outputs:

  demuxed_fastq_r1:
    type: File[]
    outputSource: wf_clashseq_preprocess_se/b1_demuxed_fastq_r1

  trimx1_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: wf_clashseq_preprocess_se/b1_trimx1_fastq
  trimx1_metrics:
    type: File[]
    outputSource: wf_clashseq_preprocess_se/b1_trimx1_metrics

  read1_fasta:
    type: File[]
    outputSource: wf_clashseq_preprocess_se/b1_read1_fasta
  collapsed_read1_fasta:
    type: File[]
    outputSource: wf_clashseq_preprocess_se/b1_collapsed_read1_fasta

steps:

###########################################################################
# Upstream
###########################################################################
  
  wf_clashseq_preprocess_se:
    run: wf_clashseq_preprocess_se.cwl
    scatter: read
    in:
      read: samples
      dataset_name: dataset_name
    out: [
      b1_demuxed_fastq_r1,
      b1_trimx1_fastq,
      b1_trimx1_metrics,
      b1_read1_fasta,
      b1_collapsed_read1_fasta,
    ]
      


###########################################################################
# Downstream (candidate for merging with main pipeline)
###########################################################################
