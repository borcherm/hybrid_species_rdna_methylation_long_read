# hybrid_species_rdna_methylation_long_read
*Overview*  
This bash pipeline was created for tabulating per-read and per-base methylation statistics of rDNA in hybrid animal species (liger, mule, etc), with rDNA units being separated by species to assess differential methylation. Due to the large file size of alignments derived from nanopore long reads and the many small files generated in this pipeline, it is designed so that the user can split the input read as many times as needed by the constraints of their filesystem. The output directories must be name results_batch1, results_batch2, and so on as many times as needed to split the input read. If the input read is not partitioned, simply name the output directory results_batch1. A recommended file size for each split is 120 GB per input fastq file (the results directory and individual alignment files will be much larger).  

*Input Files*  
  -The pipeline operates on long read fastq files that must have methylation tags (MM, ML) in the header of each read. The basecalling must therefore be done with a methylation aware config, and the tags added to the header by samtools fastq -T '*' unaligned_bam.bam or samtools fastq -T 'MM,ML' unaligned_bam.bam. The fastq file may be split as many times as necessary (recommended to not exceed 120 GB per input file).  
  -A reference fasta for the feature of interest must be provided to align to. Because this pipeline is designed for hybrids, two fasta entries are recommended, with one from each haplotype. It must be a singleline fasta, meaning each entry has one line for the header and one line for the sequence.  
  -A bed file containing annotations for sub-regions within the reference for which the user may want separate methylation averages, with sub-region name in the fourth column. For our rDNA analysis, these regions are gene body, intergenic-spacer, and promoter. If no such sub-regions are desired, you will still need to pass a bed file with the chromosome name and full coordinates of the feature, and have a unique dummy name in the fourth column. A sample bed file is provided further below.  

*Output Files*  
The output files will be stored in results_all/methylation_analysis/. Separate output files are made for each species in the hybrid. Files following the form of "species_group_summary_split.txt" will contain the mean methylation of each region in the annotation bed file passed as an input. Files in the form of "read_summary_split_filtered_species.txt" will contain per-read averages for each input read that aligned and passed quality/length filters. A subdirectory "process_all_methylation_modkit" will contain the file "per_base_methylation.bed" with average methylation for each base across the feature references for both species.

*Example Pipeline Start Command*  
bash pipeline_hybrid_alignments_step1.sh sequencing_data/slice1/ consensus_rotated_rdna/hybrid_reference_singleline.fa results_batch1 consensus_rotated_rdna/hybrid_features.bed

*Tool Versions*  
samtools 1.23.1  
htslib 1.23.1  
minimap2 2.26-r1175  
modkit 0.6.0
bedtools v2.30.0
Python 3.12.4

*Sample Bed File*  
FCA126	0	14424	gene_body
FCA126	14424	42021	igs
FCA126	42021	42221	promoter
Oge1	0	14676	gene_body
Oge1	14676	37625	igs
Oge1	37625	37825	promoter
