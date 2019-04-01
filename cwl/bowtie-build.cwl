#!/usr/bin/env cwltool

cwlVersion: v1.0
class: CommandLineTool


requirements:
- class: InlineJavascriptRequirement

inputs:

  fasta_file:
    type:
      - File
      - type: array
        items: File
    inputBinding:
      itemSeparator: ","
      position: 25
    doc: |
      comma-separated list of files with ref sequences

  index_base_name:
    type: string
    inputBinding:
      position: 26
    doc: |
      write Ebwt data to files with this basename
  offrate:
    type: int
    inputBinding:
      position: 1
      prefix: --offrate
    default: 2
    
outputs:

  indices:
    type: File[]
    outputBinding:
      glob: ${return inputs.index_base_name + "*"}

baseCommand:
  - bowtie-build