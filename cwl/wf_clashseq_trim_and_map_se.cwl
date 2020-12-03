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
    
  dataset_name:
    type: string
  species: 
    type: string
    
  read1:
    type: File
  read_name:
    type: string
  a_adapters:
    type: File
    
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
    
  read_idx_name:
    type: string
  reverse_aligned_tsv:
    type: string
  genome_aligned_sam:
    type: string
    doc: "seed based alignments (l=8, n=2)"
    
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
  S:
    type: boolean
    default: true
    
  ## samtools view params ##
  
  isbam:
    type: boolean
    default: true
    
outputs:

  X_output_trim_first:
    type: File[]
    outputSource: step_gzip_sort_X_trim/gzipped
  X_output_trim_first_metrics:
    type: File
    outputSource: X_trim/output_trim_report

  # X_output_trim_again:
  #   type: File[]
  #   outputSource: step_gzip_sort_X_trim_again/gzipped
  # X_output_trim_again_metrics:
  #   type: File
  #   outputSource: X_trim_again/output_trim_report

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
  
  mir_alignments_filtered:
    type: File
    outputSource: step_filter_bowtie_output/filtered_bowtie_tsv
    
  chimeric_alignment_candidates:
    type: File
    outputSource: step_find_chimeric_candidates/chimeric_candidates_file

  chimeric_alignment_metrics:
    type: File
    outputSource: step_find_chimeric_candidates/metrics_file

  genome_alignments_bowtie:
    type: File
    outputSource: step_map_chimeric_seqs_to_genome/output
  
  genome_alignments_star:
    type: File
    outputSource: step_map_chimeric_seqs_to_genome_star/aligned
    
  genome_alignments_star_metrics:
    type: File
    outputSource: step_map_chimeric_seqs_to_genome_star/mappingstats
  
  genome_alignments_star_unmapped:
    type: File
    outputSource: step_map_chimeric_seqs_to_genome_star/output_map_unmapped_fwd
    
  genome_alignments_star_settings:
    type: File
    outputSource: step_map_chimeric_seqs_to_genome_star/starsettings
  
  genome_alignments_sorted_bam:
    type: File
    outputSource: step_samtools_sort/output_sort_bam
    
  genome_alignments_rmdup_bam:
    type: File
    outputSource: step_dedup/output_barcodecollapsese_bam
  
  genome_alignments_rmdup_metrics:
    type: File
    outputSource: step_dedup/output_barcodecollapsese_metrics
  
  genome_alignments_bed_graph:
    type: File
    outputSource: step_genome_coverage/bedgraph_file
    
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
  
  ### Trimming twice removes too many reads due to the new adapter. Deprecated step ###
  # X_trim_again:
  #   run: trim_se.cwl
  #   in:
  #     input_trim: X_trim/output_trim
  #     input_trim_overlap_length: trimagain_overlap_length
  #     input_trim_a_adapters: get_a_adapters/output
  #     times: trim_times
  #     error_rate: trim_error_rate
  #   out: [output_trim, output_trim_report]
  
  A_sort_trimmed_fastq:
    run: fastqsort.cwl
    scatter: input_fastqsort_fastq
    in:
      # input_fastqsort_fastq: X_trim_again/output_trim
      input_fastqsort_fastq: X_trim/output_trim
    out:
      [output_fastqsort_sortedfastq]
  
  ### Trimming twice removes too many reads due to the new adapter. Deprecated step ###
  # step_gzip_sort_X_trim_again:
  #   run: gzip.cwl
  #   scatter: input
  #   in:
  #     input: A_sort_trimmed_fastq/output_fastqsort_sortedfastq
  #   out:
  #     - gzipped
      
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
  
  step_filter_bowtie_output:
    run: filter_bowtie_results.cwl
    in:
      bowtie_align: step_map_mirs/output
    out:
      - filtered_bowtie_tsv
  
  ### Replace this with a subworkflow that splits results for better memory performance ###
  # step_find_chimeric_candidates:
  #   run: find_candidate_chimeric_seqs_from_mir_alignments.cwl
  #   in:
  #     bowtie_align: step_filter_bowtie_output/filtered_bowtie_tsv
  #     fa_file: step_fastq_to_fasta/output_fasta_file
  #   out:
  #     - chimeric_candidates_file
  #     - metrics_file
  
  step_find_chimeric_candidates:
    run: wf_find_chimeric_candidates.cwl
    in:
      filtered_bowtie_tsv: step_filter_bowtie_output/filtered_bowtie_tsv
      output_fasta_file: step_fastq_to_fasta/output_fasta_file
      chimeric_candidates_filename: 
        source: step_filter_bowtie_output/filtered_bowtie_tsv
        valueFrom: ${return self.nameroot + ".chimeric_candidates.fa"}
      chimeric_metrics_filename: 
        source: step_filter_bowtie_output/filtered_bowtie_tsv
        valueFrom: ${return self.nameroot + ".metrics"}
    out:
      - chimeric_candidates_file
      - metrics_file
      
  ### Map chimeric candidates to genome with Bowtie ###
  # We may abandon this to use STAR instead.
  
  step_map_chimeric_seqs_to_genome:
    doc: "Map chimeric candidates to genome with Bowtie."
    run: bowtie-genome.cwl
    in:
      n: n
      l: l
      e: e
      sam: S
      ebwt: bowtie_genome_prefix
      bowtie_db: bowtie_genome_directory
      filelist:
        source: step_find_chimeric_candidates/chimeric_candidates_file
        valueFrom: ${return [ self ];} # Trick to allow single-end reads
      filename: genome_aligned_sam
    out:
      - output
      - output_bowtie_log
  
  ### Map chimeric candidates to genome with STAR ###
  # Deprecating the Bowtie mapper in favor of this one. 
  
  step_map_chimeric_seqs_to_genome_star:
    doc: "Map chimeric candidates to genome with STAR. This is the current aligner we'll be using."
    run: star-genome.cwl
    in:
      readFilesIn: 
        source: step_find_chimeric_candidates/chimeric_candidates_file
        valueFrom: ${ return [ self ]; }
      genomeDir: speciesGenomeDir
    out: [
      aligned,
      output_map_unmapped_fwd,
      starsettings,
      mappingstats
    ]
  
  ### We might not need this if we map with STAR? ###
  # step_sam_to_bam:
  #   run: samtools-view.cwl
  #   in:
  #     isbam: isbam
  #     input: step_map_chimeric_seqs_to_genome/output
  #   out:
  #     - output
     
  step_samtools_sort:
    run: sort.cwl
    in:
      input_sort_bam: step_map_chimeric_seqs_to_genome_star/aligned
    out:
      - output_sort_bam
  
  step_samtools_index:
    run: samtools-index.cwl
    in:
      alignments: step_samtools_sort/output_sort_bam
    out: 
      - alignments_with_index
    
  step_dedup:
    run: barcodecollapse_se.cwl
    in:
      input_barcodecollapsese_bam: step_samtools_index/alignments_with_index
    out:
      - output_barcodecollapsese_bam
      - output_barcodecollapsese_metrics
  
  step_genome_coverage:
    run: genomeCoverageBed.cwl
    in:
      input_bam: step_dedup/output_barcodecollapsese_bam
      chrom_sizes: chrom_sizes
    out:
      - bedgraph_file
      
doc: |
  This workflow takes in appropriate trimming params and demultiplexed reads,
  and performs the following steps in order: trimx1, trimx2, fastq-sort, filter repeat elements, fastq-sort, genomic mapping, sort alignment, index alignment, namesort, PCR dedup, sort alignment, index alignment
