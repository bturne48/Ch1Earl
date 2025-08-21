import os, sys

# files needed
inFile = open(sys.argv[1])
outFile = open(sys.argv[2], 'w')

# target scaffold in a strain
chrom = sys.argv[3]

# lines from vcf to target 
x = 0
for line in inFile:
    
    # if chrom colomn matches what snakemake specifies
    if line.startswith(chrom):
    
       outFile.write(line)
       x += 1 

# if file is empty, add 2 dummy lines so that the HMM will run
if x == 0:
    outFile.write(chrom +'\t'+ '1' +'\t'+ '0/0\n')
    outFile.write(chrom +'\t'+ '2' +'\t'+ '0/0\n')