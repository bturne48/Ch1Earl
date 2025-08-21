import os, subprocess
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages


list_of_input_files = ['foo.txt', 'foo2.txt']


# read in file
with open(snakemake.input[0]) as inFile1:
    lines = [line.rstrip() for line in inFile1]
    strainName = '/'.join(snakemake.input[0].split('.')[1:3])


slidingDict = {}
for x in range(0, len(lines), 10000):
    
    # add sliding info to dict
    slidingDict[str(x)+'..'+str(x+10000)] = [0,0]
    
    for y in range(x, min(x+10000, len(lines))):
        
        # parse
        splitLine = lines[y].split()
        geno = splitLine[-1]

        # counts for genos, updates dict, 0/0=REF so we ignore
        if geno=='1/1' or geno=='2/2':
            slidingDict[str(x)+'..'+str(x+10000)][0] += 1
        elif geno=='0/1' or geno=='0/2' or geno=='1/2':
            slidingDict[str(x)+'..'+str(x+10000)][1] += 1
        # elif geno == '0/0':
        #     continue
        # else:
        #     print('ERROR - Unaccounted GENO:' + geno)


# save midpoint as x-axis, het/hom as points for y-axes
xax, yax1_hom, yax2_het = [], [], []

for window in slidingDict:

    # midpoint is needed to plot
    windowMidpoint = int((int(window.split('..')[0]) + int(window.split('..')[1]))/2)

    # counts per window
    homCount, hetCount = slidingDict[window][0], slidingDict[window][1]

    # if the counts are 0, dont append, hom
    if homCount == 0 and hetCount == 0:
        continue
    
    # append values to lists
    xax.append(windowMidpoint)
    yax1_hom.append(homCount)
    yax2_het.append(hetCount)


# save all plots into a pdf
def save_image(filename):
    
    # PdfPages is a wrapper around pdf 
    # file so there is no clash and
    # create files with no error.
    p = PdfPages(filename)
      
    # get_fignums Return list of existing
    # figure numbers
    fig_nums = plt.get_fignums()  
    figs = [plt.figure(n) for n in fig_nums]
      
    # iterating over the numbers in list
    for fig in figs: 
        
        # and saving the files
        fig.savefig(p, format='pdf') 
          
    # close the object
    p.close() 


# actual plot
filename = snakemake.output[0]  
classes = ['Homozygous', 'Heterozygous']
plt.rcParams["figure.figsize"] = (10,5)
plt.title(strainName)
plt.scatter(xax, yax1_hom, alpha=0.8, facecolors='black', edgecolors='black', s=15)
plt.scatter(xax, yax2_het, alpha=0.8, facecolors='blue', edgecolors='blue', s=15)
#plt.xticks(range(5000, max(xax)+1, 10000))
plt.legend(labels=classes)
plt.xlabel('Postion (Mb)')
plt.ylabel('Geno Count')    

# save to multi pdf
save_image(filename)  




# # subset correct vcf files
# vcfs = os.listdir('/nobackup/rogers_research/Brandon/RemoteEdit/ComplexVarAlign/Mayotte/workflow/results/VCFs/')
# subVcfFiles = []
# for file in vcfs:
#     if file.endswith('.recode.chrom.GT.FORMAT'):
#         subVcfFiles.append('/nobackup/rogers_research/Brandon/RemoteEdit/ComplexVarAlign/Mayotte/workflow/results/VCFs/'+file)



