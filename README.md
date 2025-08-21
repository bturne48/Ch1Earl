Each of the rules files (.smk) exists to organize steps in the pipeline (align to reference, run an HMM on each sample, etc).

This small sample contains rules to process WGS for a few hundred samples and:
1. Create and process BAM files (BWA, samtools)
2. Create and process VCF files (bcftools)
3. Run an HMM to determine heterozygosity blocks (vcftools, bcftools, python, R)
4. Run a structural variant/transposable element caller to identify TE-mediated SVs (samtools, EarlGrey)

These rules utilize parallel processing and slurm integration to ensure that samples are processed quickly, while reatining the ability to pivot (ex. add a new sample, change reference genome, etc.). This can be seen in
```
envs/config.yaml.
```

This pipeline is organized in the standard snakemake distribution format:

```
├── .gitignore
├── workflow
│   ├── rules
|   │   ├── module1.smk
|   │   └── module2.smk
│   ├── envs
|   │   ├── tool1.yaml
|   │   └── tool2.yaml
│   ├── scripts
|   │   ├── script1.py
|   │   └── script2.R
│   ├── notebooks
|   │   ├── notebook1.py.ipynb
|   │   └── notebook2.r.ipynb
│   ├── report
|   │   ├── plot1.rst
|   │   └── plot2.rst
|   └── Snakefile
├── config
│   ├── config.yaml
│   └── some-sheet.tsv
├── results
└── resources
```
'''
