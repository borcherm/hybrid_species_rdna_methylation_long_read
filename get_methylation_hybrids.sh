#!/bin/bash

ref=$1

mkdir -p modkit_beds modkit_beds/logs read_breakdown

for bam in ../alignment/*.bam; do
    group=$(basename $bam | cut -d. -f1)
    echo "-----$group-----"
    modkit pileup \
        --threads 32 \
        --ref $ref \
        --cpg \
        --combine-strands \
        --modified-bases 5mC \
        --log modkit_beds/logs/$group.log \
        ../alignment/$group.bam \
        modkit_beds/$group.bed

    mkdir -p read_breakdown/$group read_breakdown/$group
done

ls ../alignment/read_breakdown/ | while read type
do
    mkdir -p alignment/$type/modkit_beds alignment/$type/modkit_beds/logs
    ls ../alignment/read_breakdown/$type | while read ALIGNMENT
    do
        for aln in ../alignment/read_breakdown/$type/$ALIGNMENT/*.bam; do
            num=$(basename $aln | cut -d. -f1)
            echo $aln
            mv $aln ../alignment/read_breakdown/$type/$ALIGNMENT/$ALIGNMENT\_$num.bam
            samtools index ../alignment/read_breakdown/$type/$ALIGNMENT/$ALIGNMENT\_$num.bam
            mv *.bai ../alignment/read_breakdown/$type/$ALIGNMENT
            modkit pileup \
                --threads 32 \
                --ref $ref \
                --cpg \
                --combine-strands \
                --modified-bases 5mC \
                --log alignment/$type/modkit_beds/logs/$num.log \
                ../alignment/read_breakdown/$type/$ALIGNMENT/$ALIGNMENT\_$num.bam \
                alignment/$type/modkit_beds/$ALIGNMENT\_$num.bed
        done
    done
done


#ls ../alignment/snp | while read type
#do
#  cd ../alignment/snp/$type
#  ls *bam > bam_files.txt
#  touch all.bam
#  samtools merge -f all.bam -b bam_files.txt
#  samtools sort all.bam > all_sorted.bam
#  samtools index all_sorted.bam
#  cd ../../../get_methylation
#  modkit pileup \
#      --threads 32 \
#      --ref $ref \
#      --cpg \
#      --combine-strands \
#      --ignore h \
#      --only-tabs \
#      --log modkit_beds/logs/$type.log \
#      ../alignment/snp/$type/all_sorted.bam \
#      modkit_beds/$type.bed
#done
