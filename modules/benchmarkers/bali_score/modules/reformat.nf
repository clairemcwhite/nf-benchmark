/*
 * Reformats an alignment using mview
 */

params.format_in = "fasta"
params.format_out = "msf"

process REFORMAT {    
    tag { id }
    publishDir "${params.outdir}/bali_base"
    container 'cbcrg/baliscore-v3.1@sha256:11a9bdfce8cb9310038dd6f63f46e915dccd3a197942983435e1538db815a705'
           
    input:
    tuple val (id), path (target_aln), path (ref_aln)

    output:
    tuple val (id), path ('tool.log'), path (ref_aln), path ('tool.txt'), path ('path.txt'), path ('bin.log')//, path ('opt.tree')

    script:
    """    
    printf "%s\n" \$BASH_VERSION >> bin.log
    cat  ${target_aln} > tool.log
    echo $PATH > path.txt
    mview -in ${params.format_in} -out msf ${target_aln} > tool.txt 2>&1 || exit 0
    # ls /opt/mview/bin > opt.tree
    mview -in ${params.format_in} -out msf ${target_aln} > ${target_aln}.${params.format_out}
    """
}

/*
mview -in ${params.format_in} -out msf ${target_aln} > tool.log 2>&1


mview -in ${params.format_in} -out msf ${target_aln} > ${target_aln}.${params.format_out}
mview -in ${params.format_in} -out msf ${target_aln} > ${target_aln}.${params.format_out}    
    
/Users/jaespinosa/nxf_scratch/31/7c0848afc0f622be7fefb93f3babe2
*/