#minimum_length is the minimum length for an outbred region that we keep
minimum_length = 10000 #default from Nick and paper
#we cluster all kept outbred regions that are within maximum_cluster_distance of each other
#maximum_cluster_distance = 50000 #default from Nick
maximum_cluster_distance = 100000 #default from paper

#previously_kept_outbred keeps track of whether we are at the very beginning of the file or not
#previous_chrom, previous_begin, and previous_end keep track only for kept outbred regions
previous_chrom = list(snakemake.config["lengths"][snakemake.wildcards.ref].keys())[0]
previous_begin, previous_end = 0, 0
previously_kept_outbred = False
lastHet = False

with open(snakemake.input[0], "r") as input_file, open(snakemake.output[0], "w") as output_file:
	for line in input_file:
		chrom, begin, end, state, length = line.strip().split()
		begin = int(begin)
		end = int(end)
		length = int(length)
		#if we keep this outbred region
		if state == "hetero" and length >= minimum_length:
			#if this kept outbred region overlaps the previous kept outbred region
			#previously_kept_outbred ensures that this is not the very first kept outbred region
			#(since there would be no previously kept outbred region)
			if ((previously_kept_outbred) and (chrom == previous_chrom) and (begin <= previous_end + maximum_cluster_distance)):
				previous_begin = previous_begin
			#if this kept outbred region doesn't overlap the previous kept outbred region
			else:
				#if there was not a previously kept outbred region
				if not previously_kept_outbred:
					previously_kept_outbred = True
				#if there was a previously kept outbred region
				else:
					#write the previous outbred region
					output_file.write(f"{previous_chrom}\t{previous_begin}\t{previous_end}\t{'hetero'}\t{previous_end-previous_begin+1}\n")
				previous_begin = begin
			#these keep track only for kept outbred regions
			previous_chrom = chrom
			previous_end = end
			lastHet = True

		# BRANDON ADD, so it prints both states
		if state == "Inbred" and length >= minimum_length:
			#if this kept outbred region overlaps the previous kept outbred region
			#previously_kept_outbred ensures that this is not the very first kept outbred region
			#(since there would be no previously kept outbred region)
			if ((previously_kept_outbred) and (chrom == previous_chrom) and (begin <= previous_end + maximum_cluster_distance)):
				previous_begin = previous_begin
			#if this kept outbred region doesn't overlap the previous kept outbred region
			else:
				#if there was not a previously kept outbred region
				if not previously_kept_outbred:
					previously_kept_outbred = True
				#if there was a previously kept outbred region
				else:
					#write the previous outbred region
					output_file.write(f"{previous_chrom}\t{previous_begin}\t{previous_end}\t{'Inbred'}\t{previous_end-previous_begin+1}\n")
				previous_begin = begin
			#these keep track only for kept outbred regions
			previous_chrom = chrom
			previous_end = end
			lastHet = False


	lastChrom = 'Inbred'
	if lastHet == True:
		lastChrom = 'hetero'		
	
	#write the final kept outbred region
	#(in the for loop we only ever write the previous kept outbred region)
	output_file.write(f"{previous_chrom}\t{previous_begin}\t{previous_end}\t{lastChrom}\t{previous_end-previous_begin+1}\n")
