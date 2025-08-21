#I'm basing the values in this code off of the section "residual heterozygosity"
#from the paper Tandem duplications and the limits of natural selection in
#Drosophila yakuba and Drosophila simulans
#They write:
#prior probabilities on states were set as: [0.5, 0.5]
#transition probabilities were set to: [[1-10^-10, 10^-10][10^-10, 1-10^-10]]
#emission probabilities were set to: [[theta, e][1-theta, 1-e]] #this notation is the transpose from what the HMM R package expects (it expects rows to sum to 1)
#where e = 0.001 and theta=0.01
#the most likely path was calculated using the Viterbi algorithm
#heterozygous segments 10kb or longer were retained
#heterozygous blocks within 100kb of one another in a sample strain
#were clustered together as a single segment
#to define the span of residual heterozygosity within inbred lines

library('HMM')

#SNP genotype input is from vcftools --extract-FORMAT-info GT
#I also used add_missing_sites.py to add the genotype "0/0" to any missing sites
#note that add_missing_sites.py only writes positions for the chromosomes in config.yaml

#get input filename for genotypes
input_genotype_filename = snakemake@input[[1]]
#input_genotype_filename = '/nobackup/rogers_research/Brandon/RemoteEdit/ComplexVarAlign/Mayotte/workflow/results/VCFs/Dyak_Tai18E2.SOU15.X.SNP.recode.chrom.GT.FORMAT'

#get output filename for viterbi
output_viterbi = snakemake@output[[1]]
#output_viterbi = 'test_vitRhyk.txt'

#load genotype file
#genotype file has 3 columns: CHROM, POS, GT
#e.g.: 2L 830 1/1
#GT can be "0/0", "0/1", "1/1", or "1/2"
genotype = read.table(input_genotype_filename, colClasses=c("character", "integer", "character"))

#rename columns
names(genotype) = c("CHROM", "POS", "GT")

#add SYMBOL as fourth column
genotype_to_symbol = function(genotype)
{
	inbreds = c("1/1", '2/2')
	outbreds = c("0/1", "1/2")
	ref_contam = c("0/0")
	if (genotype %in% inbreds)
	{
		return("i")
	}
	if (genotype %in% outbreds)
	{
		return("o")
	}

	if (genotype %in% ref_contam)
	{
		return("r")
	}
	#the above if statements should hopefully include all the genotypes
	#if not, stop the program with an error
	print(genotype)
	stop()
}
genotype$SYMBOL = vapply(genotype$GT, genotype_to_symbol, character(1))
head(genotype, 500)

#initial HMM parameters
States = c("hetero", "Inbred", "Reference")
Symbols = c("o", "i", "r")
startProbs=c(.333,.333,.333)#HMM package expects each row to add to 1
transProbs=matrix(c(.9999999999,.0000000001,.0000000001,.0000000001,.9999999999,.0000000001,.0000000001,.0000000001,.9999999999),3)
emissionProbs=matrix(c(.02,.0001,.00009,.004, .021,.0003,.976,.979,.999), nrow=3, byrow=FALSE)
#Initialize HMM
hmm = initHMM(States, Symbols, startProbs = startProbs, transProbs = transProbs, emissionProbs = emissionProbs)
observations = genotype[, 4]

#use viterbi to get most probable states
vt_states = viterbi(hmm, observations)
#add STATE column to input data with the viterbi states
genotype$STATE = vt_states

#write to output_viterbis
write.table(genotype, file=output_viterbi, row.names=FALSE, col.names=FALSE, quote=FALSE)
