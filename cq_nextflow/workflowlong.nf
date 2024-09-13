nextflow.enable.dsl=2

params.out = "$launchDir/output"

process downloadFile {
 publishDir params.out, mode: "copy", overwrite: true
 output:
  path "batch1.fasta"
"""
wget https://tinyurl.com/cqbatch1 -O batch1.fasta
"""
}

process countSequences {
publishDir params.out, mode: "copy", overwrite: true
 input:
  path infile 
  output:
  path "numseqs.txt"

"""
grep "^>" $infile | wc -l > numseqs.txt
"""
}

workflow {
 fastachannel = downloadFile()
 countSequences(fastachannel)
}
