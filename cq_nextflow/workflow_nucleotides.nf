nextflow.enable.dsl=2

params.url = "https://tinyurl.com/cqbatch1"
params.out = "$launchDir/output"

process downloadUrl {
  publishDir params.out, mode: "copy", overwrite: true
  output:
    path "batch1.fasta"
"""
wget $params.url -O batch1.fasta
"""	
}

process splitSequences {
 publishDir params.out, mode: "copy", overwrite: true
  input: 
   path infile
  
  output:
  path "splitlines_*.fasta"
"""
split -l 2 -d --additional-suffix=.fasta $infile splitlines_
"""
 }
 
 
 process GCcount {
  publishDir params.out, mode: "copy", overwrite: true 
   input: 
    path infile
   output:
    path "${infile.getSimpleName()}.GCcounts.txt"
    
"""
grep -o [GC] ${infile} | wc -l > ${infile.getSimpleName()}.GCcounts.txt
"""
 }

 process makeReport {
  publishDir params.out, mode: "copy", overwrite: true
  input:
   path infile
  output:
   path "finalGCcount.md"
 """
 cat * > GCcount.md
 echo "#Sequence number, GCcounts" > finalGCcount.md
 cat GCcount.md >> finalGCcount.md
 """
}  
 
 workflow {
 downloadUrl | splitSequences | flatten | GCcount | collect | makeReport

 }