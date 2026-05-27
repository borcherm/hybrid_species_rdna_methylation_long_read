#!/bin/bash

BASE_DIR=$(pwd)
fastq_path=$1
ref=$2
out_dir=$3
annotation=$4

prefix=$(basename $ref | cut -d. -f1)
echo $prefix
mkdir -p $out_dir $out_dir/alignment $out_dir/get_methylation $out_dir/methylation_analysis

cd $out_dir/alignment

bash $BASE_DIR/map_to_ref_hybrids.sh $BASE_DIR/$fastq_path $BASE_DIR/$ref $prefix $BASE_DIR
bash $BASE_DIR/split_alignments_hybrids.sh $BASE_DIR

READ_BREAKDOWN="read_breakdown"

cd ../get_methylation

bash $BASE_DIR/get_methylation_hybrids.sh $BASE_DIR/$ref

cd ../methylation_analysis

bash $BASE_DIR/get_read_summary_hybrids_from_bed_v3.sh $BASE_DIR/$ref $BASE_DIR/$annotation
