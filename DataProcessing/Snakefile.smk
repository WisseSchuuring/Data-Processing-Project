import expand as expand

SAMPLES = ['Sample1', 'Sample2']

rule all:
    input:
        expand('results/{sample}.txt', sample = SAMPLES)

rule quantify_genes:
    input:
        genome = 'genome.fa',
        r1 = 'data/{sample}.R1.fastq.gz',
        r2 = 'data/{sample}.R2.fastq.gz'
    output:
        'results/{sample}.txt'
    shell:
        'echo {input.genome} {input.r1} {input.r2} > {output}'


