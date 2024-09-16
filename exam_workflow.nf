nextflow.enable.dsl = 2

params.accession = "M21012"
params.out = "${launchDir}/results_${params.accession}"

process downloading_data {
    publishDir "${params.out}", mode: "copy", overwrite: true
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

workflow {
    print params.accession
    downloading_data(Channel.from(params.accession))
}