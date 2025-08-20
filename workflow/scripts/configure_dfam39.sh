# first, change directory to the famdb library location
cd /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/share/RepeatMasker/Libraries/famdb/

# download the partitions you require from Dfam 3.9. In the below, change the numbers or range inside the square brackets to choose your subsets.
# e.g. to download partitions 0 to 10: [0-10]; or to download partitions 3,5, and 7: [3,5,7]; [0-16] is ALL PARTITIONS
curl -o 'dfam39_full.#1.h5.gz' 'https://dfam.org/releases/current/families/FamDB/dfam39_full.[0-1].h5.gz'

# decompress Dfam 3.9 paritions
gunzip *.gz

# move up to RepeatMasker main directory
cd /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/share/RepeatMasker/

# save the min_init partition as a backup, just in case!
mv /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/share/RepeatMasker/Libraries/famdb/min_init.0.h5 /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/share/RepeatMasker/Libraries/famdb/min_init.0.h5.bak

# Rerun RepeatMasker configuration
perl ./configure -libdir /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/share/RepeatMasker/Libraries/ -trf_prgm /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/bin/trf -rmblast_dir /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/bin -hmmer_dir /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/bin -abblast_dir /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/bin -crossmatch_dir /projects/rogers_research/fnb/Brandon/RemoteEdit/ComplexVarAlign/Ch1Earl/workflow/.snakemake/conda/507d9f8563ebd6344937e140b9c1a09a_/bin -default_search_engine rmblast

