#!/bin/bash
# Usage: get_read_summary_hybrids_from_bed_v3.sh <ref.fa> <features.bed>
#
# Like get_read_summary_hybrids_from_bed_v2.sh, but produces one group summary
# file per chromosome (rather than per chromosome/feature pair). Each summary
# file contains per-type averages for every feature on that chromosome, plus an
# overall "all" average across all features.
#
# BED file format (tab-separated):
#   chrom   start   end   feature_name

ref=$1
features_bed=$2

if [[ -z "$ref" || -z "$features_bed" ]]; then
    echo "Usage: $0 <ref.fa> <features.bed>"
    echo "  ref.fa       - Reference FASTA file"
    echo "  features.bed - BED file with feature coordinates (chrom, start, end, feature_name)"
    exit 1
fi

if [[ ! -f "$features_bed" ]]; then
    echo "Error: BED file '$features_bed' not found"
    exit 1
fi

refname1=$(grep ">" $ref | cut -f 2 -d ">" | head -1)
refname2=$(grep ">" $ref | cut -f 2 -d ">" | tail -1)
echo "Reference 1: $refname1"
echo "Reference 2: $refname2"

# Extract unique (chrom, feature) pairs from BED file
pairs_file=$(mktemp)
awk 'NF>=4 {print $1"\t"$4}' "$features_bed" | sort -u > "$pairs_file"
echo "Chromosome/feature combinations found in BED:"
cat "$pairs_file"

# Extract unique chromosomes
chroms_file=$(mktemp)
awk '{print $1}' "$pairs_file" | sort -u > "$chroms_file"

# Initialize one output file per (chrom, feature) pair
while IFS=$'\t' read -r chrom feature; do
    tag="${chrom}_${feature}"
    rm -f "read_summary_split_${tag}.txt"
    touch "read_summary_split_${tag}.txt"
done < "$pairs_file"

# Build awk position-range condition for a specific (chrom, feature) pair
build_awk_condition() {
    local bed_file=$1
    local chrom=$2
    local feature=$3
    local conditions=""

    while IFS=$'\t' read -r bed_chrom start end name; do
        if [[ "$bed_chrom" == "$chrom" && "$name" == "$feature" ]]; then
            if [[ -n "$conditions" ]]; then
                conditions="$conditions || "
            fi
            conditions="${conditions}(\$2 >= $start && \$2 < $end)"
        fi
    done < "$bed_file"

    echo "$conditions"
}

while read -r type; do
    echo "Processing type: $type"
    for bed in ../get_methylation/alignment/$type/modkit_beds/*.bed; do
        if [[ ! -f "$bed" ]]; then
            continue
        fi
        readname=$(echo $bed | cut -d \/ -f5)
        num=$(basename $bed | cut -d. -f1)
        refname=$(cut -f 1 "$bed" | head -1)

        while IFS=$'\t' read -r chrom feature; do
            if [[ "$refname" != "$chrom" ]]; then
                continue
            fi

            tag="${chrom}_${feature}"
            region="${type}_${feature}"
            awk_condition=$(build_awk_condition "$features_bed" "$chrom" "$feature")

            if [[ -n "$awk_condition" ]]; then
                meth_pct=$(awk "$awk_condition" "$bed" | awk '{sum+=$12} END {if(NR>0) print sum/NR; else print "NA"}')
                echo -e "$region\t$readname\t$num\t$meth_pct" >> "read_summary_split_${tag}.txt"
            fi
        done < "$pairs_file"
    done
done < <(ls ../alignment/read_breakdown/)

# Create filtered files for each (chrom, feature) pair
while IFS=$'\t' read -r chrom feature; do
    tag="${chrom}_${feature}"
    input_file="read_summary_split_${tag}.txt"
    filtered_file="read_summary_split_filtered_${tag}.txt"
    grep "\." "$input_file" > "$filtered_file" 2>/dev/null || touch "$filtered_file"
done < "$pairs_file"

# Create one group summary file per chromosome
while read -r chrom; do
    summary_file="${chrom}_group_summary_split.txt"
    rm -f "$summary_file"
    touch "$summary_file"

    echo "Summarizing chromosome: $chrom"
    while read -r type; do
        while IFS=$'\t' read -r pair_chrom feature; do
            if [[ "$pair_chrom" != "$chrom" ]]; then
                continue
            fi
            tag="${chrom}_${feature}"
            filtered_file="read_summary_split_filtered_${tag}.txt"
            pattern="${type}_${feature}"
            avg_meth_pct=$(grep "$pattern" "$filtered_file" | awk '{sum+=$4} END {if(NR>0) print sum/NR; else print "NA"}')
            region=$(grep "$pattern" "$filtered_file" | cut -f 1 | uniq)
            if [[ -n "$region" ]]; then
                echo -e "$region\t$avg_meth_pct" >> "$summary_file"
            fi
        done < "$pairs_file"
    done < <(ls ../alignment/read_breakdown/)

    # Overall average across all features for this chromosome
    all_filtered_files=()
    while IFS=$'\t' read -r pair_chrom feature; do
        if [[ "$pair_chrom" != "$chrom" ]]; then
            continue
        fi
        all_filtered_files+=("read_summary_split_filtered_${chrom}_${feature}.txt")
    done < "$pairs_file"
    avg_meth_pct=$(cat "${all_filtered_files[@]}" 2>/dev/null | awk '{sum+=$4} END {if(NR>0) print sum/NR; else print "NA"}')
    echo -e "all\t$avg_meth_pct" >> "$summary_file"

done < "$chroms_file"

rm -f "$pairs_file" "$chroms_file"

echo "Done. Output files per chromosome:"
awk 'NF>=4 {print $1}' "$features_bed" | sort -u | while read -r chrom; do
    echo "  ${chrom}_group_summary_split.txt"
done
