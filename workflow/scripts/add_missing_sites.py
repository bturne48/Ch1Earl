#dictionary of the chromosome lengths for each reference (as set in config.yaml)
ref = snakemake.wildcards.ref
chroms = snakemake.config["chroms"]
ref_to_chrom_to_length = snakemake.config["lengths"]


with open(snakemake.input[0], "r") as input_file, open(snakemake.output[0], "w") as output_file:
	
	# #output header line
	# header = input_file.readline()
	# output_file.write(header)
	# print(header)

	# brandon mod, change to bcftools doesnt provide headers like vcftools
	header = 'CHROM\tPOST\t' + snakemake.input[0]
	output_file.write(header)
	
	#initialize beginning of chromosome
	previous_chrom = ""
	previous_pos = 0

	for line in input_file:
		
		chrom, pos, gt = line.strip().split()
		pos = int(pos)

		# if the first line of the input file is not a snp at pos 1, weird edge case
		if previous_chrom == "" and previous_pos == 0 and pos !=1:
			output_file.write(f"{previous_chrom} {1} 0/0\n")

		#If we have finished a previous chromosome
		if ((chrom != previous_chrom) and (previous_chrom != "")):
			
			if previous_chrom in chroms:
				
				#write all the final positions of the previous chromosome
				previous_chrom_length = ref_to_chrom_to_length[ref][previous_chrom]
				for i in range(previous_pos + 1, previous_chrom_length+1):
					output_file.write(f"{previous_chrom} {i} 0/0\n")

			#reset for new chromosome
			previous_chrom = chrom
			previous_pos = 0
			
		#write any gaps in current chromosome between previous position and current position
		if chrom in chroms:
			
			# if this current line is not the next bp on the same chrom, write all gaps, range is exclusive for end positio
			if pos != previous_pos+1:
				for i in range(previous_pos + 1, pos):
					output_file.write(f"{chrom} {i} 0/0\n")
			output_file.write(f"{chrom} {pos} {gt}\n")

		# change iterator vars
		previous_chrom = chrom
		previous_pos = pos
