#set variables for beginning of chromosome, need a known chrom to start 
begin = 1
end = 1
previous_chrom = list(snakemake.config["lengths"][snakemake.wildcards.ref].keys())[0]
#previous_chrom = list(snakemake.config["lengths"]["Dyak_Tai18E2"].keys())[0]
previous_state = "Inbred"

with open(snakemake.input[0], "r") as input_file, open(snakemake.output[0], "w") as output_file:
	
	#read the header line
	for line in input_file:
		
		chrom, pos, GT, symbol, state = line.strip().split()
		pos = int(pos)
		
		# if this line is the same as the previous lines chrom
		if chrom == previous_chrom:
			
			# if the chrom is the same as the last line, and so is the state
			if (previous_state == state):
				end = pos
				
			
			# if we transition from Inbred to hetero but the chrom is the same
			#elif ((previous_state == "Inbred") and (state == "hetero")):
			# brandon change: make it so that if it changes from Inbred to anything that is not Inbred
			elif ((previous_state != state) and (previous_state == "Inbred")):
				end = pos - 1
				if end > 0:
					output_file.write(f"{chrom} {begin} {end} Inbred {end-begin+1}\n")
				begin = pos
				end = pos
				previous_state = state

			# brandon change: make it so that if it changes from Inbred to anything that is not Inbred
			# NOTE: the states are literal, and must match what comes out of the HMM
			elif ((previous_state != state) and (previous_state == "hetero")):
				end = pos - 1
				if end > 0:
					output_file.write(f"{chrom} {begin} {end} hetero {end-begin+1}\n")
				begin = pos
				end = pos
				previous_state = state

			elif ((previous_state != state) and (previous_state == "Reference")):
				end = pos - 1
				if end > 0:
					output_file.write(f"{chrom} {begin} {end} Reference {end-begin+1}\n")
				begin = pos
				end = pos
				previous_state = state

			# chrom is the same, but state is different, but not transitioning from Inbred
			else:
				#output_file.write(previous_state, state)
				output_file.write(f"{chrom} {begin} {end} poo {end-begin+1}\n")
				begin = end + 1
				end = pos
				previous_state = state
		
		#we have finished a chromosome, write the last region and the final Inbred/hetero/ref regions
		else:
			
			if (previous_state == "Inbred"):
				output_file.write(f"{previous_chrom} {begin} {end} Inbred {end-begin+1}\n")
			
			elif (previous_state == "hetero"):
				output_file.write(f"{previous_chrom} {begin} {end} hetero {end-begin+1}\n")

			elif (previous_state == "Reference"):
				output_file.write(f"{previous_chrom} {begin} {end} Reference {end-begin+1}\n")
			
			else:
				output_file.write(f"{previous_chrom} {begin} {end} poo {end-begin+1}\n")
			
			#set variables for beginning of next chromosome
			begin = 1
			end = 1
			previous_chrom = chrom
			previous_state = state
	
	#write the last region
	output_file.write(f"{chrom} {begin} {end} {state} {end-begin+1}\n")




