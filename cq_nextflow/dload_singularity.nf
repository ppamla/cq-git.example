nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.out="${launchDir}/out"
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

process runFastQC {
	storeDir params.storeDir
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0"
	input:
     path fastqFile
	output: 
     path "${fastqFile.getSimpleName()}_fastqc.html"

    script:
    """
	mkdir FastQC
	fastqc -o . ${fastqFile}
    """
}

workflow {
    prefetchChannel = Channel.from(params.accession)
    conversionChannel = prefetchSRA(prefetchChannel)
    conversionChannel = convertToFastq(conversionChannel)
    runFastQC(conversionChannel)
}

