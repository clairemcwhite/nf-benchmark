#!/bin/bash nextflow
//params.outdir = 'results_REG'

include {COMBINE_SEQS}      from './preprocess.nf'    
include {REG_ALIGNER}       from './generateAlignment.nf'   
include {EVAL_ALIGNMENT}    from './modules_evaluateAlignment.nf'
include {EASEL_INFO}        from './modules_evaluateAlignment.nf'
include {HOMOPLASY}         from './modules_evaluateAlignment.nf'
include {METRICS}           from './modules_evaluateAlignment.nf'

workflow REG_ANALYSIS {
  take:
    seqs_and_trees
    refs_ch
    align_method
    tree_method
    bucket_size
    
     
  main: 
    REG_ALIGNER (seqs_and_trees, align_method, bucket_size)
   
    if (params.evaluate){
      refs_ch
        .cross (REG_ALIGNER.out.alignmentFile)
        .map { it -> [ it[1][0], it[1][1], it[0][1] ] }
        .set { alignment_and_ref }

      EVAL_ALIGNMENT ("regressive", alignment_and_ref, REG_ALIGNER.out.alignMethod, REG_ALIGNER.out.treeMethod, REG_ALIGNER.out.bucketSize)
      EVAL_ALIGNMENT.out.tcScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.regressive.tcScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
      EVAL_ALIGNMENT.out.spScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.regressive.spScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
      EVAL_ALIGNMENT.out.colScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.regressive.colScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
                    
    }
    if (params.homoplasy){
      HOMOPLASY("regressive", REG_ALIGNER.out.alignmentFile, REG_ALIGNER.out.alignMethod, REG_ALIGNER.out.treeMethod, REG_ALIGNER.out.bucketSize, REG_ALIGNER.out.homoplasyFile)
      HOMOPLASY.out.homoFiles
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text};${it[6].text};${it[7].text};${it[8].text};${it[9].text};${it[10].text}" }
                    .collectFile(name: "${workflow.runName}.regressive.homo.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")  
    }

    def metrics_regressive = params.metrics? METRICS("regressive", REG_ALIGNER.out.alignmentFile, REG_ALIGNER.out.alignMethod, REG_ALIGNER.out.treeMethod, REG_ALIGNER.out.bucketSize, REG_ALIGNER.out.metricFile) : Channel.empty()
    if (params.metrics) {
        metrics_regressive.metricFiles
                          .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text};${it[6].text};${it[7].text};${it[8].text};${it[9].text}" }
                          .collectFile(name: "${workflow.runName}.regressive.metrics.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
    }

    def easel_info = params.easel? EASEL_INFO ("regressive", REG_ALIGNER.out.alignmentFile, REG_ALIGNER.out.alignMethod, REG_ALIGNER.out.treeMethod, REG_ALIGNER.out.bucketSize) : Channel.empty()
    if (params.easel) {
        easel_info.easelFiles
                  .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[6].text};${it[7].text}" }
                  .collectFile(name: "${workflow.runName}.regressive.easel.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
    }

    emit:
    alignment = REG_ALIGNER.out.alignmentFile
    metrics = metrics_regressive
    easel = easel_info

}

include {POOL_ALIGNER}   from './generateAlignment.nf'   
workflow POOL_ANALYSIS {
  take:
    seqs_and_trees
    refs_ch
    align_method
    tree_method
    bucket_size
     
  main: 
    POOL_ALIGNER (seqs_and_trees, align_method, bucket_size)
   
    if (params.evaluate){
      refs_ch
        .cross (POOL_ALIGNER.out.alignmentFile)
        .map { it -> [ it[1][0], it[1][1], it[0][1] ] }
        .set { alignment_and_ref }
    
      EVAL_ALIGNMENT ("pool", alignment_and_ref, POOL_ALIGNER.out.alignMethod, POOL_ALIGNER.out.treeMethod, POOL_ALIGNER.out.bucketSize)
      EVAL_ALIGNMENT.out.tcScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.pool.tcScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
      EVAL_ALIGNMENT.out.spScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.pool.spScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
      EVAL_ALIGNMENT.out.colScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.pool.colScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
    }
    if (params.homoplasy){
      HOMOPLASY("pool", POOL_ALIGNER.out.alignmentFile, POOL_ALIGNER.out.alignMethod, POOL_ALIGNER.out.treeMethod, POOL_ALIGNER.out.bucketSize, POOL_ALIGNER.out.homoplasyFile)
      HOMOPLASY.out.homoFiles
                  .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text};${it[6].text};${it[7].text};${it[8].text};${it[9].text};${it[10].text}" }
                  .collectFile(name: "${workflow.runName}.pool.homo.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")  
    }
    if (params.metrics){
      METRICS("pool", POOL_ALIGNER.out.alignmentFile, POOL_ALIGNER.out.alignMethod, POOL_ALIGNER.out.treeMethod, POOL_ALIGNER.out.bucketSize, POOL_ALIGNER.out.metricFile)
      METRICS.out.metricFiles
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text};${it[6].text};${it[7].text};${it[8].text};${it[9].text}" }
                    .collectFile(name: "${workflow.runName}.pool.metrics.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
    }
    if (params.easel){
      EASEL_INFO ("pool", POOL_ALIGNER.out.alignmentFile, POOL_ALIGNER.out.alignMethod, POOL_ALIGNER.out.treeMethod, POOL_ALIGNER.out.bucketSize)
      EASEL_INFO.out.easelFiles
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[6].text};${it[7].text}" }
                    .collectFile(name: "${workflow.runName}.pool.easel.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")    
    }

  emit:
  alignment = POOL_ALIGNER.out.alignmentFile
}
