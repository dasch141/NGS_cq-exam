nextflow.enable.dsl = 2

params.accession = "M21012"
params.out = "${launchDir}/results_${params.accession}"
params.in = "${launchDir}/input_fasta"

// test accession: OK349688

process download_data {
    input:
        val params.accession
    output:
        path "${params.accession}.fasta"
    script:
    """
    wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" \\
        -O ${params.accession}.fasta
    """
}

process combine_fasta {
    input:
        path infiles
    output:
        path "combined.fasta"
    script:
    """
    cat ${infiles} > combined.fasta
    """
}

process mafft {
    container "https://depot.galaxyproject.org/singularity/mafft%3A7.525--h031d066_1"
    input:
        path infile
    output:
        path "mafft.fasta"
    script:
    """
    mafft --auto ${infile} > mafft.fasta
    """
}

process trimAl {
    publishDir "${params.out}", mode: "copy", overwrite: true
    container "https://depot.galaxyproject.org/singularity/trimal%3A1.5.0--h4ac6f70_1"
    input:
        path infile
    output:
        path "seqs_compared_to_${params.accession}.fasta"
        path "seqs_compared_to_${params.accession}.html"
    script:
    """
    trimal -in ${infile} -out seqs_compared_to_${params.accession}.fasta -htmlout seqs_compared_to_${params.accession}.html -automated1
    """
}

workflow {
    download_channel = download_data(Channel.from(params.accession))
    input_fasta_channel = Channel.fromPath("${params.in}/*.fasta")
    combined_channel = download_channel.concat(input_fasta_channel)
    combine_fasta(combined_channel.collect()) | mafft | trimAl    
}