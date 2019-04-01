#!/usr/bin/env cwltool

### Workflow for handling reads containing one barcode ###
### Returns a bam file containing read2 only ###

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: MultipleInputFeatureRequirement


#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:
  dataset:
    type: string

  ## eCLIP-specific params ##

  speciesGenomeDir:
    type: Directory
  repeatElementGenomeDir:
    type: Directory

  # TODO: remove, we don't use it here.
  species:
    type: string

  chrom_sizes:
    type: File

  ## end eCLIP-specific params ##

  barcodesfasta:
    type: File

  randomer_length:
    type: string

  read:
    type:
      type: record
      fields:
        read1:
          type: File
        read2:
          type: File
        barcodeids:
          type: string[]
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
    default: "barcode1_reads_bowtie_index"
  b1_reverse_aligned_tsv:
    type: string
    default: "barcode1_reverse_miR_alignments.tsv"
  b1_genome_aligned_tsv:
    type: string
    default: "barcode1_chimeric_genome_alignments.tsv"
  b1_genome_aligned_e2e_tsv:
    type: string
    default: "barcode1_chimeric_genome_alignments_e2e.tsv"
    
  b2_read_idx_name:
    type: string
    default: "barcode2_reads_bowtie_index"
  b2_reverse_aligned_tsv:
    type: string
    default: "barcode2_reverse_miR_alignments.tsv"
  b2_genome_aligned_tsv:
    type: string
    default: "barcode2_chimeric_genome_alignments.tsv"
  b2_genome_aligned_e2e_tsv:
    type: string
    default: "barcode2_chimeric_genome_alignments_e2e.tsv"
    
outputs:


  ### DEMULTIPLEXED OUTPUTS ###


  b1_demuxed_fastq_r1:
    label: "Barcode1 read1 demultiplexed fastq"
    type: File
    outputSource: demultiplex/A_output_demuxed_read1
  b1_demuxed_fastq_r2:
    type: File
    outputSource: demultiplex/A_output_demuxed_read2

  b2_demuxed_fastq_r1:
    label: "Barcode1 read1 demultiplexed fastq"
    type: File
    outputSource: demultiplex/B_output_demuxed_read1
  b2_demuxed_fastq_r2:
    type: File
    outputSource: demultiplex/B_output_demuxed_read2

  ### TRIMMED OUTPUTS ###

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

  b2_trimx1_fastq:
    type: File[]
    outputSource: b2_trim_and_map/X_output_trim_first
  b2_trimx1_metrics:
    type: File
    outputSource: b2_trim_and_map/X_output_trim_first_metrics
  b2_trimx2_fastq:
    type: File[]
    outputSource: b2_trim_and_map/X_output_trim_again
  b2_trimx2_metrics:
    type: File
    outputSource: b2_trim_and_map/X_output_trim_again_metrics

  ### REVERSE MAPPING OUTPUTS ###

  b1_read2_fasta:
    type: File
    outputSource: b1_trim_and_map/read2_fasta
  b1_collapsed_read2_fasta:
    type: File
    outputSource: b1_trim_and_map/collapsed_read2_fasta
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
    
  b2_read2_fasta:
    type: File
    outputSource: b2_trim_and_map/read2_fasta
  b2_collapsed_read2_fasta:
    type: File
    outputSource: b2_trim_and_map/collapsed_read2_fasta
  b2_read_idx:
    type: Directory
    outputSource: b2_trim_and_map/read_idx
  b2_mir_alignments:
    type: File
    outputSource: b2_trim_and_map/mir_alignments
  b2_chimeric_alignment_candidates:
    type: File
    outputSource: b2_trim_and_map/chimeric_alignment_candidates
  b2_chimeric_alignment_metrics:
    type: File
    outputSource: b2_trim_and_map/chimeric_alignment_metrics
  b2_genome_alignments:
    type: File
    outputSource: b2_trim_and_map/genome_alignments
  b2_genome_alignments_e2e:
    type: File
    outputSource: b2_trim_and_map/genome_alignments_e2e
  #########################################################################
  # standard eCLIP outputs
  #########################################################################

    ### REPEAT MAPPING OUTPUTS ###


  b1_maprepeats_mapped_to_genome:
    type: File
    outputSource: b1_trim_and_map/A_output_maprepeats_mapped_to_genome
  b1_maprepeats_stats:
    type: File
    outputSource: b1_trim_and_map/A_output_maprepeats_stats
  b1_maprepeats_star_settings:
    type: File
    outputSource: b1_trim_and_map/A_output_maprepeats_star_settings
  b1_sorted_repunmapped_fastq:
    type: File[]
    outputSource: b1_trim_and_map/A_output_sort_repunmapped_fastq

  b2_maprepeats_mapped_to_genome:
    type: File
    outputSource: b2_trim_and_map/A_output_maprepeats_mapped_to_genome
  b2_maprepeats_stats:
    type: File
    outputSource: b2_trim_and_map/A_output_maprepeats_stats
  b2_maprepeats_star_settings:
    type: File
    outputSource: b2_trim_and_map/A_output_maprepeats_star_settings
  b2_sorted_repunmapped_fastq:
    type: File[]
    outputSource: b2_trim_and_map/A_output_sort_repunmapped_fastq


  ### GENOME MAPPING OUTPUTS ###


  b1_mapgenome_mapped_to_genome:
    type: File
    outputSource: b1_trim_and_map/A_output_mapgenome_mapped_to_genome
  b1_mapgenome_stats:
    type: File
    outputSource: b1_trim_and_map/A_output_mapgenome_stats
  b1_mapgenome_star_settings:
    type: File
    outputSource: b1_trim_and_map/A_output_mapgenome_star_settings
  b1_sorted_genomeunmapped_r1_fastq:
    type: File
    outputSource: b1_trim_and_map/A_output_sort_genomeunmapped_r1_fastq
  b1_sorted_genomeunmapped_r2_fastq:
    type: File
    outputSource: b1_trim_and_map/A_output_sort_genomeunmapped_r2_fastq

  b2_mapgenome_mapped_to_genome:
    type: File
    outputSource: b2_trim_and_map/A_output_mapgenome_mapped_to_genome
  b2_mapgenome_stats:
    type: File
    outputSource: b2_trim_and_map/A_output_mapgenome_stats
  b2_mapgenome_star_settings:
    type: File
    outputSource: b2_trim_and_map/A_output_mapgenome_star_settings
  b2_sorted_genomeunmapped_r1_fastq:
    type: File
    outputSource: b2_trim_and_map/A_output_sort_genomeunmapped_r1_fastq
  b2_sorted_genomeunmapped_r2_fastq:
    type: File
    outputSource: b2_trim_and_map/A_output_sort_genomeunmapped_r2_fastq

  ### RMDUP BAM OUTPUTS ###


  b1_output_prermdup_sorted_bam:
    type: File
    outputSource: b1_trim_and_map/A_output_sorted_bam
  b1_output_barcodecollapsepe_bam:
    type: File
    outputSource: b1_trim_and_map/X_output_barcodecollapsepe_bam
  b1_output_barcodecollapsepe_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_barcodecollapsepe_metrics

  b2_output_prermdup_sorted_bam:
    type: File
    outputSource: b2_trim_and_map/A_output_sorted_bam
  b2_output_barcodecollapsepe_bam:
    type: File
    outputSource: b2_trim_and_map/X_output_barcodecollapsepe_bam
  b2_output_barcodecollapsepe_metrics:
    type: File
    outputSource: b2_trim_and_map/X_output_barcodecollapsepe_metrics


  ### SORTED RMDUP BAM OUTPUTS ###


  b1_output_sorted_bam:
    type: File
    outputSource: b1_trim_and_map/X_output_sorted_bam
  b2_output_sorted_bam:
    type: File
    outputSource: b2_trim_and_map/X_output_sorted_bam


  ### READ2 MERGED BAM OUTPUTS ###


  output_r2_bam:
    type: File
    outputSource: view_r2/output


  ### BIGWIG FILES ###


  output_pos_bw:
    type: File
    outputSource: make_bigwigs/posbw
  output_neg_bw:
    type: File
    outputSource: make_bigwigs/negbw

steps:

###########################################################################
# Upstream -
# - demultiplexes reads
# - removes inline barcodes from read 1
# - removes UMIs from read 2
# - places UMIs into read header
###########################################################################

  demultiplex:
    run: wf_demultiplex_pe.cwl
    in:
      dataset: dataset
      randomer_length: randomer_length
      barcodesfasta: barcodesfasta
      read: read
    out: [
      A_output_demuxed_read1,
      A_output_demuxed_read2,
      B_output_demuxed_read1,
      B_output_demuxed_read2,
      AB_output_trimfirst_overlap_length,
      AB_output_trimagain_overlap_length,
      AB_g_adapters,
      AB_g_adapters_default,
      AB_a_adapters,
      AB_a_adapters_default,
      AB_A_adapters
    ]

  trimfirst_file2string:
    run: file2string.cwl
    in:
      file: demultiplex/AB_output_trimfirst_overlap_length
    out: [output]

  trimagain_file2string:
    run: file2string.cwl
    in:
      file: demultiplex/AB_output_trimagain_overlap_length
    out: [output]

  b1_trim_and_map:
    run: wf_clashseq_trim_and_map_pe.cwl
    in:
      trimfirst_overlap_length: trimfirst_file2string/output
      trimagain_overlap_length: trimagain_file2string/output
      g_adapters: demultiplex/AB_g_adapters
      g_adapters_default: demultiplex/AB_g_adapters_default
      a_adapters: demultiplex/AB_a_adapters
      a_adapters_default: demultiplex/AB_a_adapters_default
      A_adapters: demultiplex/AB_A_adapters
      read1: demultiplex/A_output_demuxed_read1
      read2: demultiplex/A_output_demuxed_read2
      mirna_fasta: mirna_fasta
      bowtie_genome_prefix: bowtie_genome_prefix
      bowtie_genome_directory: bowtie_genome_directory
      read_idx_name: b1_read_idx_name
      reverse_aligned_tsv: b1_reverse_aligned_tsv
      genome_aligned_tsv: b1_genome_aligned_tsv
      genome_aligned_tsv_e2e: b1_genome_aligned_e2e_tsv
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
    out: [
      X_output_trim_first,
      X_output_trim_first_metrics,
      X_output_trim_again,
      X_output_trim_again_metrics,
      read2_fasta,
      collapsed_read2_fasta,
      read_idx,
      mir_alignments,
      chimeric_alignment_candidates,
      chimeric_alignment_metrics,
      genome_alignments,
      genome_alignments_e2e,
      A_output_maprepeats_mapped_to_genome,
      A_output_maprepeats_stats,
      A_output_maprepeats_star_settings,
      A_output_sort_repunmapped_fastq,
      A_output_mapgenome_mapped_to_genome,
      A_output_mapgenome_stats,
      A_output_mapgenome_star_settings,
      A_output_sort_genomeunmapped_r1_fastq,
      A_output_sort_genomeunmapped_r2_fastq,
      A_output_sorted_bam,
      A_output_sorted_bam_index,
      X_output_barcodecollapsepe_bam,
      X_output_barcodecollapsepe_metrics,
      X_output_sorted_bam,
      X_output_index_bai
    ]

  b2_trim_and_map:
    run: wf_clashseq_trim_and_map_pe.cwl
    in:
      trimfirst_overlap_length: trimfirst_file2string/output
      trimagain_overlap_length: trimagain_file2string/output
      g_adapters: demultiplex/AB_g_adapters
      g_adapters_default: demultiplex/AB_g_adapters_default
      a_adapters: demultiplex/AB_a_adapters
      a_adapters_default: demultiplex/AB_a_adapters_default
      A_adapters: demultiplex/AB_A_adapters
      read1: demultiplex/B_output_demuxed_read1
      read2: demultiplex/B_output_demuxed_read2
      mirna_fasta: mirna_fasta
      bowtie_genome_prefix: bowtie_genome_prefix
      bowtie_genome_directory: bowtie_genome_directory
      read_idx_name: b2_read_idx_name
      reverse_aligned_tsv: b2_reverse_aligned_tsv
      genome_aligned_tsv: b2_genome_aligned_tsv
      genome_aligned_tsv_e2e: b2_genome_aligned_e2e_tsv
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
    out: [
      X_output_trim_first,
      X_output_trim_first_metrics,
      X_output_trim_again,
      X_output_trim_again_metrics,
      read2_fasta,
      collapsed_read2_fasta,
      read_idx,
      mir_alignments,
      chimeric_alignment_candidates,
      chimeric_alignment_metrics,
      genome_alignments,
      genome_alignments_e2e,
      A_output_maprepeats_mapped_to_genome,
      A_output_maprepeats_stats,
      A_output_maprepeats_star_settings,
      A_output_sort_repunmapped_fastq,
      A_output_mapgenome_mapped_to_genome,
      A_output_mapgenome_stats,
      A_output_mapgenome_star_settings,
      A_output_sort_genomeunmapped_r1_fastq,
      A_output_sort_genomeunmapped_r2_fastq,
      A_output_sorted_bam,
      A_output_sorted_bam_index,
      X_output_barcodecollapsepe_bam,
      X_output_barcodecollapsepe_metrics,
      X_output_sorted_bam,
      X_output_index_bai
    ]

  merge:
    run: samtools-merge.cwl
    in:
      input_bam_files: [
        b1_trim_and_map/X_output_sorted_bam,
        b2_trim_and_map/X_output_sorted_bam
      ]
    out: [output_bam_file]

###########################################################################
# Downstream (candidate for merging with main pipeline)
###########################################################################

  view_r2:
    run: samtools-viewr2.cwl
    in:
      input: merge/output_bam_file
      readswithbits:
        default: 128
      isbam:
        default: true
    out: [output]

  make_bigwigs:
    run: makebigwigfiles.cwl
    in:
      chromsizes: chrom_sizes
      bam: view_r2/output
    out:
      [posbw, negbw]