#!/bin/bash nextflow

process CLUST_SEMANTIC {
    tag "semantic alignment on $id"
    publishDir "${params.outdir}/alignments", pattern: '*aln'
    // container 'cbcrg/tcoffee@sha256:8894ba57a7ff34965d8febd51dcb7765b71314ca06893bc473d32e22032bf66f'

    input:
    tuple val (id), path(seqs), path(embeddings)

    output:

    val "semantic", emit: alignMethod
    tuple val (id), path ("${id}.clustering.semantic.aln"), emit: alignmentFile
    path ".command.trace", emit: metricFile
 
    script:
    """    
    python /home/cmcwhite/transformer_infrastructure/hf_aligner2.py -i ${seqs} -e ${embeddings} -o ${id}.clustering.semantic.aln
    """
}

