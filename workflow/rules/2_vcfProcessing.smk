def get_ref_fasta(wildcards):
	return config["refs"][wildcards.ref]


rule bcftools_mpileup:
	input:
		bam="results/1_BAMs/{ref}.{strain}.markdup.bam",
		bai="results/1_BAMs/{ref}.{strain}.markdup.bam.bai"
	output:
		temp("results/2_VCFs/{ref}.{strain}.raw.bcf")
	params:
		ref = lambda wildcards: config["refs"]["{}".format(wildcards.ref)]
	conda:
		'../envs/footools.yaml'
	shell:
		"bcftools mpileup -a INFO/AD,FORMAT/AD,FORMAT/DP  -d 100000000 -Ou --threads {resources.cpus_per_task} -f {params.ref} {input.bam} > {output}"


rule bcftools_call:
	input:
		"results/2_VCFs/{ref}.{strain}.raw.bcf"
	output:
		protected("results/2_VCFs/{ref}.{strain}.vcf.gz")
	conda:
		'../envs/footools.yaml'	
	shell:
		"bcftools call -Oz -m -f GQ --threads {resources.cpus_per_task} {input} > {output}"


# rule compress_vcfs:
# 	input:
# 		"results/2_VCFs/{ref}.vcf"
# 	output:
# 		protected("results/2_VCFs/{ref}.vcf.gz")
# 	conda:
# 		'../envs/footools.yaml'
# 	shell:
# 		"bgzip --threads {resources.cpus_per_task} {input}"


rule index_vcfs:
	input:
		"results/2_VCFs/{ref}.{strain}.vcf.gz"
	output:
		protected("results/2_VCFs/{ref}.{strain}.vcf.gz.tbi")
	conda:
		'../envs/footools.yaml'
	shell:
		'tabix -p vcf {input}'