# rule vcftools_recode_snpsOnly:
# 	input:
# 		vcf = "results/2_VCFs/{ref}.{strain}.vcf.gz",
# 		idx = 'results/2_VCFs/{ref}.{strain}.vcf.gz.tbi'
# 	output:
# 		temp("results/3_HMM/ModVCF/{ref}.{strain}.SNP.recode.vcf")
# 	params:
# 		outPrefix = lambda wc: 'results/3_HMM/ModVCF/{wildcards.ref}.{wildcards.strain}.SNP'
# 	shell:
# 		"vcftools --gzvcf {input.vcf} --remove-indels --recode --recode-INFO-all --out {params.outPrefix}"

# rule vcftools_extract:
# 	input:
# 		vcf = "results/3_HMM/ModVCF/{ref}.{strain}.SNP.recode.vcf",
# 	output:
# 		temp("results/3_HMM/ModVCF/{ref}.{strain}.SNP.recode.GT.FORMAT")
# 	params:
# 		outPrefix = lambda wc: 'results/3_HMM/ModVCF/{wildcards.ref}.{wildcards.strain}.SNP.recode'
# 	shell:
# 		"vcftools --vcf {input.vcf} --extract-FORMAT-info GT --out {params}"

# rule bcftools_recode_snpsOnly:
# 	input:
# 		vcf = "results/2_VCFs/{ref}.{strain}.vcf.gz",
# 		idx = 'results/2_VCFs/{ref}.{strain}.vcf.gz.tbi'
# 	output:
# 		temp("results/3_HMM/ModVCF/{ref}.{strain}.SNP.vcf.gz")
# 	conda:
# 		"../envs/footools.yaml"
# 	shell:
# 		"bcftools view --threads {resources.cpus_per_task} -Oz --types snps {input.vcf} -o {output}"


# rule bcftools_extract:
# 	input:
# 		"results/3_HMM/ModVCF/{ref}.{strain}.SNP.vcf.gz",
# 	output:
# 		temp("results/3_HMM/ModVCF/{ref}.{strain}.SNP.recode.GT.FORMAT")
# 	conda:
# 		"../envs/footools.yaml"
# 	shell:
# 		"bcftools query -f '%CHROM %POS [ %GT]\n' {input} -o {output}"


# rule add_missing_sites:
# 	input:
# 		"results/3_HMM/ModVCF/{ref}.{strain}.SNP.recode.GT.FORMAT"
# 	output:
# 		protected("results/3_HMM/ModVCF/{ref}.{strain}.SNP.recode.FULL.GT.FORMAT")
# 	script:
# 		"../scripts/Haplotypes/add_missing_sites.py"


# rule get_chrom_format:
# 	input:
# 		"results/3_HMM/ModVCF/{ref}.{strain}.SNP.recode.FULL.GT.FORMAT"
# 	output:
# 		temp("results/3_HMM/ModVCF/{ref}.{strain}.SNP.recode.{chrom}.GT.FORMAT")
# 	shell:
# 		"python scripts/Haplotypes/filterChrom.py {input} {output} {wildcards.chrom}"


# # TODO: make an R env to use with conda
# rule HMM:
# 	input:
# 		"results/3_HMM/ModVCF/{ref}.{strain}.SNP.recode.{chrom}.GT.FORMAT"
# 	output:
# 		temp("results/3_HMM/HMM.{ref}.{strain}.SNP.recode.{chrom}.viterbi")
# 	threads:
# 		4
# 	script:
# 		"../scripts/Haplotypes/HMM_dyak.R"


# rule combine_viterbi:
# 	input:
# 		lambda wildcards: expand("results/3_HMM/HMM.{{ref}}.{{strain}}.SNP.recode.{chrom}.viterbi", chrom=config['chroms'])
# 	output:
# 		temp("results/3_HMM/{ref}.{strain}.SNP.recode.FULL.viterbi")
# 	shell:
# 		"cat {input} > {output}"


# rule get_het_regions:
# 	input:
# 		"results/3_HMM/{ref}.{strain}.SNP.recode.FULL.viterbi"
# 	output:
# 		temp("results/3_HMM/{ref}.{strain}.SNP.recode.FULL.regions")
# 	script:
# 		"../scripts/Haplotypes/get_het_regions.py"


# rule cluster_het_regions:
# 	input:
# 		"results/3_HMM/{ref}.{strain}.SNP.recode.FULL.regions"
# 	output:
# 		protected("results/3_HMM/{ref}.{strain}.SNP.recode.FULL.regions.clustered")
# 	script:
# 		"../scripts/Haplotypes/cluster_het_regions.py"


# rule make_freqtable:
# 	input:
# 		ancient("Clusters/{ref}.SUMMARY.{kind}.putativemutationclusters.tsv"),
# 		expand("3_HMM/{{ref}}.{strain}.SNP.recode.FULL.regions.clustered", strain=config["strains"])
# 	output:
# 		"Clusters/{ref}.SUMMARY.{kind}.putativemutationclusters.freqtable.tsv"
# 	script:
# 		"scripts/make_freqtable.py"