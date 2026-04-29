ref=$1

modkit pileup \
        --threads 32 \
        --ref $ref \
        --cpg \
        --combine-strands \
        --filter-threshold C:0.8\
        --modified-bases 5mC \
        --log modkit_beds/logs/all_aligned_reads_combined.log \
        all_reads_sorted.bam \
        per_base_methylation.bed
