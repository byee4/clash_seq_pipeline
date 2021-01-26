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
  species:
    type: string

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
              
  mirna_fasta:
    type: File
  bowtie_genome_prefix:
    type: string
  bowtie_genome_directory:
    type: Directory
  
  speciesGenomeDir:
    type: Directory
  chrom_sizes:
    type: File
  b1_read_idx_name:
    type: string
    default: "reads_bowtie_index"
  b1_reverse_aligned_tsv:
    type: string
    default: "reverse_miR_alignments.tsv"
  b1_genome_aligned_sam:
    type: string
    default: "chimeric_genome_alignments.sam"
    
outputs:

  demuxed_fastq_r1:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_demuxed_fastq_r1

  trimx1_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: wf_clashseqcore_se_1barcode/b1_trimx1_fastq
  trimx1_metrics:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_trimx1_metrics
  trimx2_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: wf_clashseqcore_se_1barcode/b1_trimx2_fastq
  trimx2_metrics:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_trimx2_metrics
  trimx_umi_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: wf_clashseqcore_se_1barcode/b1_trimx_umi_fastq
  trimx_umi_metrics:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_trimx_umi_metrics
    
  ### REVERSE MAPPING OUTPUTS ###

  read1_fasta:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_read1_fasta
  collapsed_read1_fasta:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_collapsed_read1_fasta
  read_idx:
    type: Directory[]
    outputSource: wf_clashseqcore_se_1barcode/b1_read_idx
  mir_alignments:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_mir_alignments
  mir_alignments_filtered:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_mir_alignments_filtered
  chimeric_alignment_candidates:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_chimeric_alignment_candidates
  chimeric_alignment_metrics:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_chimeric_alignment_metrics
  genome_alignments_bowtie:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_genome_alignments_bowtie
  genome_alignments_star:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_genome_alignments_star
  genome_alignments_star_metrics:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_genome_alignments_star_metrics
  genome_alignments_star_unmapped:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_genome_alignments_star_unmapped
  genome_alignments_star_settings:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_genome_alignments_star_settings
  genome_alignments_star_sorted_bam:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_genome_alignments_star_sorted_bam
  genome_alignments_star_rmdup_bam:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_genome_alignments_star_rmdup_bam
  genome_alignments_star_rmdup_metrics:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_genome_alignments_star_rmdup_metrics
  genome_alignments_star_bedgraph:
    type: File[]
    outputSource: wf_clashseqcore_se_1barcode/b1_genome_alignments_star_bedgraph
  # clipper_peaks:
  #   type: File[]
  #   outputSource: wf_clashseqcore_se_1barcode/b1_clipper_peaks
steps:

###########################################################################
# Upstream
###########################################################################
  
  wf_clashseqcore_se_1barcode:
    run: wf_clashseqcore_se_1barcode.cwl
    scatter: read
    in:
      read: samples
      dataset_name: dataset_name
      species: species
      mirna_fasta: mirna_fasta
      bowtie_genome_prefix: bowtie_genome_prefix
      bowtie_genome_directory: bowtie_genome_directory
      speciesGenomeDir: speciesGenomeDir
      chrom_sizes: chrom_sizes
    out: [
      b1_demuxed_fastq_r1,
      b1_trimx1_fastq,
      b1_trimx1_metrics,
      b1_trimx2_fastq,
      b1_trimx2_metrics,
      b1_trimx_umi_fastq,
      b1_trimx_umi_metrics,
      b1_read1_fasta,
      b1_collapsed_read1_fasta,
      b1_read_idx,
      b1_mir_alignments,
      b1_mir_alignments_filtered,
      b1_chimeric_alignment_candidates,
      b1_chimeric_alignment_metrics,
      b1_genome_alignments_bowtie,
      b1_genome_alignments_star,
      b1_genome_alignments_star_metrics,
      b1_genome_alignments_star_unmapped,
      b1_genome_alignments_star_settings,
      b1_genome_alignments_star_sorted_bam,
      b1_genome_alignments_star_rmdup_bam,
      b1_genome_alignments_star_rmdup_metrics,
      b1_genome_alignments_star_bedgraph,
      # b1_clipper_peaks
    ]
      


###########################################################################
# Downstream (candidate for merging with main pipeline)
###########################################################################
