//this line enables nextflow version dsl=2 to run 

nextflow.enable.dsl=2

//use this variable parameter in order to make sure you can publish your output from 
//and into any folder to make it workable by another person as well.
//parameters can easily adjust your workflow's behaviour and make it more user-friendly
//path in quotations when it is not a variable  - name of a folder, where youre running the script/output - not a variable. 
//therefore it needs to be a string.$ variable launchdir appended to the /output folder, even though it is just a string, 
//it is saving path plus the folder 
 
params.out = "$launchDir/output"


//this is the process download to download a file with wget as the command inbetween 3 quotations from the link-database. 
//you need to give it a place to save the file to in output and the path defines gives it a name

process downloadFile {
 publishDir params.out, mode: "copy", overwrite: true
 output:
  path: "batch1.fasta"
"""
wget https://tinyurl.com/cqbatch1 -O batch1.fasta
"""
}

process downloadUrl

//in the command line we use grep to grab lines that starts with > from the input file, 
//and we give it the name infile because we won't know what the input file is named necessarily...
//so we can give it a variable like infile(input file) and then give it a name with path in output.
//"numseqs" is a string with the name of the file vs infile a variable because we dont know the name


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

//this is another process to be run after downloading, counting. 
//Here we are splitting and the output path includes an underscore because you will have however many splits as defined by the command. 
//asterix is the wild card to take care of creating how ever many splits are found 
//no forward arrow here to give the infile the name splitseqs because the split command already has 

process splitSequences{
 publishDir params.out, mode: "copy", overwrite: true
 input:
  path infile 
 output:
  path "splitseqs_*.fasta"

"""
split -l 2 -d --additional-suffix=.fasta $infile splitseqs_
 
"""
}

//forward arrow into 

process countBases {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}.basecount"
  """
  grep -v "^>" $infile | wc -m > ${infile.getSimpleName()}.basecount
  """
}

process countRepeats {
 publishDir params.out, mode: "copy", overwrite: true
  input:
   path infile
  output: 
   path "${infile.getSimpleName()}.repeatcounts"
"""
grep -o "GCCGCG" $infile | wc -l > ${infile.getSimpleName()}.repeatcounts
"""
}



workflow {
 downloadFile | splitSequences | flatten | countRepeats
}

