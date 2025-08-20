strains = config['strains']
pops = config['populations']
chroms = config['chroms']
lengths = config['lengths']
refs = config['refs']
anscRefs = 'Dtei_GT53w'
fastqs=config['fastqs']

rna_samples = list(config["RNAfastq"].keys())
rna_tissues = {
    sample: list(config["RNAfastq"][sample].keys())
    for sample in rna_samples
}
rna_pairs = [(s, t) for s in rna_samples for t in rna_tissues[s]]


all_populations = list(config["populations"].keys())
non_control_pops = [p for p in all_populations if p != "Control"]

# long_samples = []
# for sample in config["fastqs"]:
#     if (
#         "pacbio_hifi" in config["fastqs"][sample]
#         or "pacbio_clr" in config["fastqs"][sample]
#         or "ont" in config["fastqs"][sample]
#     ):
#         long_samples.append(sample)

# short_and_long_samples = []
# for short_sample in short_samples:
#     if short_sample in long_samples:
#         short_and_long_samples.append(short_sample)

# refs = config["ref"]
# junction_overhang = config["junction_overhang"]
# max_insertions = config["max_insertions"]
# read_support = config["read_support"]
# strongthreshold = 1000
# short_read_spanning_alignment_minimum_matching_bp = 30
# short_read_spanning_alignment_minimum_transcriptomic_insertion_size = 215
# short_read_spanning_alignment_maximum_transcriptomic_insertion_size = 485
# junction_strong_short_read_support_threshold = 1


# def get_minimap_preset(wildcards):
#     if wildcards.tech == "pacbio_hifi":
#         return "map-hifi"
#     elif wildcards.tech == "pacbio_clr":
#         return "map-pb"
#     else:
#         assert wildcards.tech == "ont"
#         return "map-ont"


# def get_sorted_bam_transcriptome_short(wildcards):
#     files = []
#     if "short" in config["fastqs"][wildcards.sample]:
#         i_s = config["fastqs"][wildcards.sample]["short"]
#         for i in i_s:
#             file = f"results/BAMS/{wildcards.ref}/{wildcards.sample}/transcriptome/short/{wildcards.ref}.{wildcards.sample}.transcriptome.illumina.{i}.sorted.bam"
#             files.append(file)
#     return files


# def get_sorted_bam_transcriptome_long(wildcards):
#     files = []
#     if "pacbio_hifi" in config["fastqs"][wildcards.sample]:
#         i_s = config["fastqs"][wildcards.sample]["pacbio_hifi"]
#         for i in i_s:
#             file = f"results/BAMS/{wildcards.ref}/{wildcards.sample}/transcriptome/pacbio_hifi/{wildcards.ref}.{wildcards.sample}.transcriptome.temp.pacbio_hifi.{i}.sorted.bam"
#             files.append(file)
#     if "pacbio_clr" in config["fastqs"][wildcards.sample]:
#         i_s = config["fastqs"][wildcards.sample]["pacbio_clr"]
#         for i in i_s:
#             file = f"results/BAMS/{wildcards.ref}/{wildcards.sample}/transcriptome/pacbio_clr/{wildcards.ref}.{wildcards.sample}.transcriptome.temp.pacbio_clr.{i}.sorted.bam"
#             files.append(file)
#     if "ont" in config["fastqs"][wildcards.sample]:
#         i_s = config["fastqs"][wildcards.sample]["ont"]
#         for i in i_s:
#             file = f"results/BAMS/{wildcards.ref}/{wildcards.sample}/transcriptome/ont/{wildcards.ref}.{wildcards.sample}.transcriptome.temp.ont.{i}.sorted.bam"
#             files.append(file)
#     return files


# def get_sorted_bam_genome_short(wildcards):
#     files = []
#     i_s = config["fastqs"][wildcards.sample]["short"]
#     for i in i_s:
#         file = f"results/BAMS/{wildcards.ref}/{wildcards.sample}/genome/short/{wildcards.ref}.{wildcards.sample}.genome.illumina.{i}.sorted.bam"
#         files.append(file)
#     return files


# def get_sorted_bam_genome_long(wildcards):
#     files = []
#     if "pacbio_hifi" in config["fastqs"][wildcards.sample]:
#         i_s = config["fastqs"][wildcards.sample]["pacbio_hifi"]
#         for i in i_s:
#             file = f"results/BAMS/{wildcards.ref}/{wildcards.sample}/genome/pacbio_hifi/{wildcards.ref}.{wildcards.sample}.genome.pacbio_hifi.{i}.sorted.bam"
#             files.append(file)
#     if "pacbio_clr" in config["fastqs"][wildcards.sample]:
#         i_s = config["fastqs"][wildcards.sample]["pacbio_clr"]
#         for i in i_s:
#             file = f"results/BAMS/{wildcards.ref}/{wildcards.sample}/genome/pacbio_clr/{wildcards.ref}.{wildcards.sample}.genome.pacbio_clr.{i}.sorted.bam"
#             files.append(file)
#     if "ont" in config["fastqs"][wildcards.sample]:
#         i_s = config["fastqs"][wildcards.sample]["ont"]
#         for i in i_s:
#             file = f"results/BAMS/{wildcards.ref}/{wildcards.sample}/genome/ont/{wildcards.ref}.{wildcards.sample}.genome.ont.{i}.sorted.bam"
#             files.append(file)
#     return files
