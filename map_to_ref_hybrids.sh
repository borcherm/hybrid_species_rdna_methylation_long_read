#!/bin/bash


fastq_path=$1
ref=$2
prefix=$3
SCRIPT_DIR=$4

mkdir -p temp read_breakdown

for fastq in $fastq_path/*; do
    group=$(basename $fastq | cut -d. -f1)
    echo "$group"
    echo $(which minimap2)
    minimap2 \
    -t 32 \
    -a \
    -x map-ont \
    -y \
    --MD \
    -Y \
    $ref \
    $fastq \
    | samtools view -@32 -F 260 -h -O SAM \
    > temp/$group.sam

    samtools view -@32 temp/$group.sam > temp/$group.no_header.sam
    samtools view -@32 -H temp/$group.sam > temp/$group.just_header.sam

    paftools.js sam2paf temp/$group.sam > temp/$group.paf

    python $SCRIPT_DIR/filter_both.py temp/$group.no_header.sam temp/$group.paf sam > temp/$group.filtered.sam
    python $SCRIPT_DIR/filter_both.py temp/$group.no_header.sam temp/$group.paf paf > temp/$group.filtered.paf

    echo $1 $3 $4 $5
    awk '{print $1, $3, $4, $5}' temp/$group.filtered.paf > temp/$group.filtered.bed
    grep_str=$(bash $SCRIPT_DIR/get_chimeras.sh temp/$group.filtered.bed)
    if [[ $grep_str == "" ]]; then
        cp temp/$group.filtered.paf $group.paf
        cp temp/$group.filtered.bed $group.bed
#        cat temp/$group.just_header.sam temp/$group.filtered.sam | samtools sort -@32 -O BAM --write-index -o $group.bam##idx##$group.bam.bai -
        cat temp/$group.just_header.sam temp/$group.filtered.sam | samtools sort -@32 -O BAM -o $group.bam -
        samtools index $group.bam
    else
        grep -v -E $grep_str temp/$group.filtered.paf > $group.paf
        grep -v -E $grep_str temp/$group.filtered.bed > $group.bed
#        cat temp/$group.just_header.sam temp/$group.filtered.sam | grep -v -E $grep_str | samtools sort -@32 -O BAM --write-index -o $group.bam##idx##$group.bam.bai -
        cat temp/$group.just_header.sam temp/$group.filtered.sam | grep -v -E $grep_str | samtools sort -@32 -O BAM -o $group.bam -
        samtools index $group.bam
    fi

    echo -e "final alignments (reads to ref) $(cat $group.paf | wc -l)"
done
