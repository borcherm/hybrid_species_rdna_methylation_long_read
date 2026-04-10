# hybrid_species_rdna_methylation_long_read
*Overview*
This bash pipeline was created for tabulating per-read and per-base methylation statistics of rDNA in hybrid animal species (liger, mule, etc). Due to the large file size of alignments derived from nanopore long reads and the many small files generated in this pipeline, it is designed so that the user can split the input read as many times as needed by the constraints of their filesystem. The output directories must be name results_batch1, results_batch2, and so on as many times as needed to split the input read. If the input read is not partitioned, simply name the output directory results_batch1. A recommended file size for each split is 120 GB per input fastq file (the results directory and individual alignment files will be much larger).  

*Input Files*
The pipeline operates on long read fastq files that must have methylation tags (MM, ML) in the header of each read. The basecalling must therefore be done with a methylation aware config, and the tags added to the header by samtools fastq -T '*' unaligned_bam.bam or samtools fastq -T 'MM,ML' unaligned_bam.bam. The fastq file may be split as many times as necessary (recommended to not exceed 120 GB per input file).

*Output Files*
The output files will be stored in results_all/methylation_analysis/. Th
