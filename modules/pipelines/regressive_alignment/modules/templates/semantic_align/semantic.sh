#!/bin/bash

# What's happening here is that we're getting the location of conda in the subshell
source \$(conda info --json | awk '/conda_prefix/ { gsub(/"|,/, "", \$2); print \$2 }')/bin/activate hf-transformers
python3 /home/cmcwhite/transformer_infrastructure/hf_aligner2.py -i ${seqs} -e ${embeddings} -o ${id}.clustering.semantic.aln
