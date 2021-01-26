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

  speciesGenomeDir:
    type: Directory

  repeatElementGenomeDir:
    type: Directory

  species:
    type: string

  chrom_sizes:
    type: File
  
  samples:
    type: 
      type: array
      items:
        type: record
        fields:
          read1:
            type: File
          read2:
            type: File
          name: 
            type: string
          adapters:
            type: File
          primer:
            type: string

outputs:

  demuxed_fastq_r1:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_demuxed_fastq_r1

  trimx1_fastq:
    type: 
      type: array
      items:
        type: array
        items: File
    outputSource: wf_clashseqcore_targeted/b1_trimx1_fastq
  trimx1_metrics:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_trimx1_metrics
  trimx1_fastqc_report:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_trimx1_fastqc_report
  trimx1_fastqc_stats: 
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_trimx1_fastqc_stats
  trimx2_fastq:
    type: 
      type: array
      items:
        type: array
        items: File
    outputSource: wf_clashseqcore_targeted/b1_trimx2_fastq
  trimx2_metrics:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_trimx2_metrics
  trimx2_fastqc_report:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_trimx2_fastqc_report
  trimx2_fastqc_stats: 
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_trimx2_fastqc_stats
    
  maprepeats_mapped_to_genome:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_maprepeats_mapped_to_genome
  maprepeats_stats:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_maprepeats_stats
  maprepeats_star_settings:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_maprepeats_star_settings
  sorted_unmapped_fastq:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_sorted_unmapped_fastq

  mapgenome_mapped_to_genome:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_mapgenome_mapped_to_genome
  mapgenome_stats:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_mapgenome_stats
  mapgenome_star_settings:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_mapgenome_star_settings

  output_pre_rmdup_sorted_bam:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_output_pre_rmdup_sorted_bam

  output_barcodecollapsese_metrics:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_output_barcodecollapsese_metrics

  output_rmdup_sorted_bam:
    type: File[]
    outputSource: wf_clashseqcore_targeted/b1_output_rmdup_sorted_bam

  output_pos_bw:
    type: File[]
    outputSource: wf_clashseqcore_targeted/output_pos_bw
  output_neg_bw:
    type: File[]
    outputSource: wf_clashseqcore_targeted/output_neg_bw

steps:

###########################################################################
# Upstream
###########################################################################
  
  wf_clashseqcore_targeted:
    run: wf_clashseqcore_targeted.cwl
    scatter: read
    in:
      dataset: dataset
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      chrom_sizes: chrom_sizes
      read: samples
    out: [
      b1_demuxed_fastq_r1,
      b1_trimx1_fastq,
      b1_trimx1_metrics,
      b1_trimx1_fastqc_report,
      b1_trimx1_fastqc_stats,
      b1_trimx2_fastq,
      b1_trimx2_metrics,
      b1_trimx2_fastqc_report,
      b1_trimx2_fastqc_stats,
      b1_maprepeats_mapped_to_genome,
      b1_maprepeats_stats,
      b1_maprepeats_star_settings,
      b1_sorted_unmapped_fastq,
      b1_mapgenome_mapped_to_genome,
      b1_mapgenome_stats,
      b1_mapgenome_star_settings,
      b1_output_pre_rmdup_sorted_bam,
      b1_output_barcodecollapsese_metrics,
      b1_output_rmdup_sorted_bam,
      output_pos_bw,
      output_neg_bw
    ]