#!/usr/bin/env cwltool

doc: |
  This workflow returns the reproducible number of split peaks given a single
  bam file and its size-matched input pair. This workflow splits the bam file
  first, but does not do anything to the input.

cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
inputs:

  fastq_file:
    type: File
  mirna_fasta:
    type: File
  bowtie_genome_prefix:
    type: string
  bowtie_genome_directory:
    type: Directory

  read_idx_name:
    type: string
    default: "reads_bowtie_index"
  reverse_aligned_tsv:
    type: string
    default: "reverse_miR_alignments.tsv"
  genome_aligned_tsv:
    type: string
    default: "chimeric_genome_alignments.tsv"

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

outputs:

  filtered_fa:
    type: File
    outputSource: step_fastq_filter/filtered_file

  collapsed_fa:
    type: File
    outputSource: step_fasta2collapse/collapsed_file

  trim3p_fa:
    type: File
    outputSource: step_trim3p/trimmed_file

  trim5p_fa:
    type: File
    outputSource: step_trim5p/trimmed_file

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

  # rmDup_alignments:
  #   type: File
  #   outputSource: step_tag2collapse/rmDup_file

steps:

  step_fastq_filter:
    run: fastq_filter.cwl
    in:
      input_file: fastq_file
    out:
      - filtered_file

  step_fasta2collapse:
    run: fasta2collapse.cwl
    in:
      input_file: step_fastq_filter/filtered_file
    out:
      - collapsed_file

  step_trim3p:
    run: fastx_clipper.cwl
    in:
      input_file: step_fasta2collapse/collapsed_file
    out:
      - trimmed_file

  step_trim5p:
    run: fastx_trimmer.cwl
    in:
      input_file: step_trim3p/trimmed_file
    out:
      - trimmed_file

  step_stripBarcode:
    run: stripBarcode.cwl
    in:
      input_file: step_trim5p/trimmed_file
    out:
      - stripped_file

  step_index_reads:
    run: bowtie-build.cwl
    in:
      fasta_file: step_stripBarcode/stripped_file
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
      fa_file: step_stripBarcode/stripped_file
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

  # step_tag2collapse:
  #   run: tag2collapse.cwl
  #   in:
  #     input_file: step_map_chimeric_seqs_to_genome/output
  #   out:
  #     - rmDup_file
doc: |
  Clash seq pipeline
