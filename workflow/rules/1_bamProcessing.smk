# zip ref if not already in gz
rule bgzip:
	output:
		protected("results/0_Refs/{ref}.fasta.gz")
	params:
		ref = lambda wildcards: config["refs"]["{}".format(wildcards.ref)],
	shell:
		"bgzip --threads {resources.cpus_per_task} -c {params.ref} > {output}"


# index ref
rule bwa_index:
	input:
		"results/0_Refs/{ref}.fasta.gz"
	output:
		"results/0_Refs/{ref}.fasta.gz.amb",
		"results/0_Refs/{ref}.fasta.gz.ann",
		"results/0_Refs/{ref}.fasta.gz.bwt",
		"results/0_Refs/{ref}.fasta.gz.pac",
		"results/0_Refs/{ref}.fasta.gz.sa"
	shell:
		"bwa index {input}"


# get a list of all fastqs from config
def get_fastq(wildcards):
	return config["fastqs"][wildcards.fastq][int(wildcards.i)]


# evaluate # of supporting reads in stains
rule read_count_table:
	input:
		fastq=get_fastq
	output:
		temp("results/1_BAMs/ReadCounts/{ref}.{fastq}.{i}.reads_per_strain.txt")
	conda:
		"../envs/samtools.yaml"
	shell:
		'echo -n -e "{wildcards.fastq}_{wildcards.i}\t" >> {output}| zcat {input} |awk -v OFMT="%.10f" \'{{s++}}END{{print s/4}}\'>> {output}'
	
rule merge_read_count_table:
	input:
		in1 = expand('results/1_BAMs/ReadCounts/{ref}.{fastq}.1.reads_per_strain.txt', ref=refs, fastq=fastqs),
		in2 = expand('results/1_BAMs/ReadCounts/{ref}.{fastq}.2.reads_per_strain.txt', ref=refs, fastq=fastqs)
	output:
		'results/1_BAMs/ReadCounts/{ref}_reads_per_strain.txt'
	shell:
		'sed "" {input} > {output} | sort -V -o {output} {output}'


# align all fastqs to the ref using bwa
# TODO : maybe make it so you can use other programs 
rule bwa_aln:
	input:
		"results/0_Refs/{ref}.fasta.gz.amb",
		"results/0_Refs/{ref}.fasta.gz.ann",
		"results/0_Refs/{ref}.fasta.gz.bwt",
		"results/0_Refs/{ref}.fasta.gz.pac",
		"results/0_Refs/{ref}.fasta.gz.sa",
		ref="results/0_Refs/{ref}.fasta.gz",
		fastq=get_fastq
	output:
		temp("results/1_BAMs/{ref}.{fastq}.{i}.sai")
	conda:
		"../envs/bwa.yaml"
	shell:
		"bwa aln -t {resources.cpus_per_task} {input.ref} {input.fastq} > {output}"


# Generate alignments in the SAM format given paired-end reads. Repetitive read pairs will be placed randomly.
rule bwa_sampe:
	input:
		ref="results/0_Refs/{ref}.fasta.gz",
		sai1="results/1_BAMs/{ref}.{fastq}.1.sai",
		sai2="results/1_BAMs/{ref}.{fastq}.2.sai",
		fastq1 = lambda wildcards: config["fastqs"][wildcards.fastq][1],
		fastq2 = lambda wildcards: config["fastqs"][wildcards.fastq][2]
	output:
		temp("results/1_BAMs/{ref}.{fastq}.sam")
	shell:
		"bwa sampe {input.ref} {input.sai1} {input.sai2} {input.fastq1} {input.fastq2} > {output}"


# convert from sam to bam
rule samtools_view:
	input:
		"results/1_BAMs/{ref}.{fastq}.sam"
	output:
		temp("results/1_BAMs/{ref}.{fastq}.original.bam")
	conda:
		"../envs/samtools.yaml"
	shell:
		"samtools view -S --threads {resources.cpus_per_task} -b {input} > {output}"


# merge sam files for multiple runs of the same strain to create a merged bam
rule samtools_cat:
	input:
		expand('results/1_BAMs/{ref}.{fastq}.original.bam', ref=refs, fastq=fastqs)
	output:
		temp("results/1_BAMs/{ref}.{strain}.merged.bam")
	conda:
		"../envs/samtools.yaml"
	params:
		lambda wc: ' '.join("results/1_BAMs/"+"{}.".format(wc.ref)+fastq+".original.bam" for fastq in config["strains"][wc.strain])
	shell:
		"samtools cat --threads {resources.cpus_per_task} {params} -o {output}"


# collate ensures that reads of the same name are grouped together in contiguous groups
rule samtools_collate:
	input:
		"results/1_BAMs/{ref}.{strain}.merged.bam"
	output:
		temp("results/1_BAMs/{ref}.{strain}.namecollate.bam")
	params:
		tmp="results/1_BAMs/tmp.{ref}.{strain}"
	conda:
		"../envs/samtools.yaml"
	shell:
		"samtools collate --threads {resources.cpus_per_task} -o {output} {input} {params.tmp}"


# Fill in mate coordinates, ISIZE and mate related flags from a name-sorted or name-collated alignment.
rule samtools_fixmate:
	input:
		"results/1_BAMs/{ref}.{strain}.namecollate.bam"
	output:
		temp("results/1_BAMs/{ref}.{strain}.fixmate.bam")
	conda:
		"../envs/samtools.yaml"
	shell:
		"samtools fixmate --threads {resources.cpus_per_task} -m {input} {output}"


# sort, duh
rule samtools_sort:
	input:
		"results/1_BAMs/{ref}.{strain}.fixmate.bam"
	output:
		temp("results/1_BAMs/{ref}.{strain}.positionsort.bam")
	conda:
		"../envs/samtools.yaml"
	shell:
		"samtools sort --threads {resources.cpus_per_task} -o {output} {input}"
		

# Mark duplicate alignments from a coordinate sorted file that has been run through samtools fixmate
rule samtools_markdup:
	input:
		"results/1_BAMs/{ref}.{strain}.positionsort.bam"
	output:
		protected("results/1_BAMs/{ref}.{strain}.markdup.bam")
	conda:
		"../envs/samtools.yaml"
	shell:
		"samtools markdup --threads {resources.cpus_per_task} {input} {output}"


# index the final bam
rule samtools_index:
	input:
		"results/1_BAMs/{ref}.{strain}.markdup.bam"
	output:
		protected("results/1_BAMs/{ref}.{strain}.markdup.bam.bai")
	conda:
		"../envs/samtools.yaml"
	shell:
		"samtools index -@ {resources.cpus_per_task} {input}"