#The fasta reference containing one entry for the feature from each hybrid, supplied as the first argument in the bash invocation
ref=$1

#make a results directory that combines the runs from slices of the file
mkdir results_all

#copy the individual unit bed files from each sub-run and perform the per-read methylation analysis
rsync -av -f"+ */" -f"- *" "results_batch1/" "./results_all/"
ls ./ | grep results_batch | while read slice
do
	cd results_all/get_methylation/alignment/*/modkit_beds/
	ln -s ../../../../../$slice/get_methylation/alignment/*/modkit_beds/*bed ./
	cd ../../../../../
done
cd results_all/methylation_analysis/
cp ../../get_read_summary_hybrids.sh .
bash get_read_summary_hybrids.sh $ref
cd ../../

#copy the full filtered bam files from each sub-run and do a modkit per-base methylation tabulation
cd results_all/methylation_analysis/
mkdir process_all_methylation_modkit
cd process_all_methylation_modkit/
ln -s ../../../results_batch*/alignment/*bam .
firstfile=$(ls | grep \.bam | head -1)
samtools view -H $firstfile > all_aligned_slices.sam
find ./ -name \*.bam -exec samtools view {} \; >> all_aligned_slices.sam
samtools sort --output-fmt BAM -o all_reads_sorted.bam --write-index all_aligned_slices.sam

bash ../../../modkit.sh ../../../$ref
cd ../../../
