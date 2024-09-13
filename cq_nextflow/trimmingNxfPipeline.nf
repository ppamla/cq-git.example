nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.out="${launchDir}/out"
params.in = "${launchDir}/data/*.fastq"
params.with_fastp = false

//params.stats="${launchDir}/stats"
params.accession="SRR16641606"

process prefetchSRA {
	storeDir params.storeDir
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
input:
 val accession
output: 
 path "${accession}"
script:
"""
prefetch $accession
"""
}

process convertToFastq {
    storeDir params.storeDir
	publishDir params.out
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	input:
     path accession
    output:
     path "${accession}.fastq"

    script:
    """
    fasterq-dump $accession
    """
}

//dump fast quality control before running fastp a trimming tool that trims off adapters 2 bases.

process runFastQC {
	storeDir params.storeDir
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0"
	input:
     path fastqFile
	output: 
     path "${fastqFile.getSimpleName()}_fastqc.*"

    script:
    """
	fastqc -o . ${fastqFile}
    """
}

process fastp {
	storeDir params.storeDir
	publishDir params.in, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastp%3A0.23.4--h125f33a_5"
input:
    path fastqFile
output:
    path "fastp_output/*"
    script:
    """
    mkdir -p fastp_output
    fastp -i $fastqFile -o fastp_output/${fastqFile.getSimpleName()}
    """
}



workflow {
    prefetchChannel = Channel.from(params.accession)
    conversionChannel = prefetchSRA(prefetchChannel)
    fastqChannel = convertToFastq(conversionChannel)
  fastpChannel = Channel.empty()
  
if (params.with_fastp) {
    fastpChannel = fastpChannel.concat(fastp(fastqChannel)) 
    }
    // Concatenate channels
    concatChannel = fastqChannel.concat(fastpChannel)
runFastQC(concatChannel) 

    // Run FastQC after fastp if fastp is enabled
    
}