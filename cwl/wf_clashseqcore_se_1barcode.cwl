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
  
  speciesGenomeDir:
    type: Directory
  chrom_sizes:
    type: File
    
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
  b1_trimx_umi_fastq:
    type: File[]
    outputSource: b1_trim_and_map/X_output_trim_umi
  b1_trimx_umi_metrics:
    type: File
    outputSource: b1_trim_and_map/X_output_trim_umi_metrics
    
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
  b1_mir_alignments_filtered:
    type: File
    outputSource: b1_trim_and_map/mir_alignments_filtered
  b1_chimeric_alignment_candidates:
    type: File
    outputSource: b1_trim_and_map/chimeric_alignment_candidates
  b1_chimeric_alignment_metrics:
    type: File
    outputSource: b1_trim_and_map/chimeric_alignment_metrics
  b1_genome_alignments_bowtie:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_bowtie
  b1_genome_alignments_star:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_star
  b1_genome_alignments_star_metrics:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_star_metrics
  b1_genome_alignments_star_unmapped:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_star_unmapped
  b1_genome_alignments_star_settings:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_star_settings
  b1_genome_alignments_star_sorted_bam:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_sorted_bam
  b1_genome_alignments_star_rmdup_bam:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_rmdup_bam
  b1_genome_alignments_star_rmdup_metrics:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_rmdup_metrics
  b1_genome_alignments_star_bedgraph:
    type: File
    outputSource: b1_trim_and_map/genome_alignments_bed_graph
  
  # b1_clipper_peaks:
  #   type: File
  #   outputSource: b1_clipper/output_bed
    
steps:

###########################################################################
# Upstream
###########################################################################

  demultiplex:
    run: wf_demultiplex_se.cwl
    in:
      dataset: dataset_name
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
      dataset_name: demultiplex/dataset_name
      species: species
      
      read1: demultiplex/A_output_demuxed_read1
      read_name: demultiplex/read_name
      a_adapters: 
        source: read
        valueFrom: |
          ${
            return self.adapters;
          }
      
      mirna_fasta: mirna_fasta
      bowtie_genome_prefix: bowtie_genome_prefix
      bowtie_genome_directory: bowtie_genome_directory
      speciesGenomeDir: speciesGenomeDir
      chrom_sizes: chrom_sizes
      
      read_idx_name: 
        source: read
        valueFrom: |
          ${
            return self.name + ".bowtie_index";
          }
        
      reverse_aligned_tsv: 
        source: read
        valueFrom: |
          ${
            return self.name + ".reverse_mir_alignments.tsv";
          }
          
      genome_aligned_sam: 
        source: read
        valueFrom: |
          ${
            return self.name + ".bowtieAligned.sam";
          }
      
    out: [
      X_output_trim_first,
      X_output_trim_first_metrics,
      X_output_trim_again,
      X_output_trim_again_metrics,
      X_output_trim_umi,
      X_output_trim_umi_metrics,
      read1_fasta,
      collapsed_read1_fasta,
      read_idx,
      mir_alignments,
      mir_alignments_filtered,
      chimeric_alignment_candidates,
      chimeric_alignment_metrics,
      genome_alignments_bowtie,
      genome_alignments_star,
      genome_alignments_star_metrics,
      genome_alignments_star_unmapped,
      genome_alignments_star_settings,
      genome_alignments_sorted_bam,
      genome_alignments_rmdup_bam,
      genome_alignments_rmdup_metrics,
      genome_alignments_bed_graph
    ]
    
  ### We will be using the standard eCLIP clipper peak clusters instead of this ###
  # b1_clipper:
  #   run: clipper.cwl
  #   in: 
  #     species: species
  #     bam: b1_trim_and_map/genome_alignments_rmdup_bam
  #   out: [
  #     output_bed
  #   ]

###########################################################################
# Downstream (candidate for merging with main pipeline)
###########################################################################
