# get a list of all fastqs from config
rule bam2fasta_no_interleave:
	input:
		'/projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch3TandemDups/workflow/results/1_BAMs/Dyak_Tai18E2.{strain}.markdup.bam'
	output:
		'results/1_fastaProcess/fastas/{strain}.fa.gz'
	conda:
		'../envs/footools.yaml'
	shell:
		'samtools fasta -t --threads {resources.cpus_per_task} {input} > {output}'
		

# get a list of all fastqs from config
rule earl_grey:
	input:
		config['refs']['Dyak_Tai18E2']
	output:
		'results/1_fastaProcess/EarlGrey/'
	params:
		#'/projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/results/1_fastaProcess/EarlGrey_{strain}/'
	conda:
		'../envs/earl.yaml'
	shell:
		#'earlGrey -g {input} -s {wildcards.strain} -o {params} -t {resources.cpus_per_task}'
		'earlGrey -g {input} -s Dyak_Tai18E2 -o {output} -t {resources.cpus_per_task}'
