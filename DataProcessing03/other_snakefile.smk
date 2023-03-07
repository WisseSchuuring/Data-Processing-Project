configfile: "config.yaml"
from snakemake.remote.NCBI import RemoteProvider as NCBIRemoteProvider
NCBI = NCBIRemoteProvider(email="w.s.f.schuuring@st.hanze.nl")
url = 'https://bioinf.nl/~fennaf/snakemake/test.txt'


rule download:
    output:
        "downloaded_test.txt"
    shell:
        "wget {url}{output}"


rule NCBI_download:
    input:
        NCBI.remote("KY785484.1.fasta", db = "nuccore")

SAMPLES = ["A","B","C"]
workdir: "/homes/wsfschuuring/Desktop/Thema11-12/DataProcessing03/data"
samples = "samples/"

rule all:
    input:
        "calls/all.vcf"

rule bwa_map:
    input:
        genome = "genome.fa",
        arg= samples + "{sample}.fastq"
    output:
        "mapped_reads/{sample}.bam"
    message: "executing bwa mem on the following {input} to generate the following {output}"
    shell:
        "bwa mem {input} | samtools view -Sb - > {output}"

rule samtools_sort:
    input:
        "mapped_reads/{sample}.bam"
    output:
        "sorted_reads/{sample}.bam"
    shell:
        "samtools sort -T sorted_reads/{wildcards.sample} "
        "-O bam {input} > {output}"

rule samtools_index:
    input:
        "sorted_reads/{sample}.bam"
    output:
        "sorted_reads/{sample}.bam.bai"
    shell:
        "samtools index {input}"

rule bcftools_call:
    input:
        fa = "genome.fa",
        bam = expand("sorted_reads/{sample}.bam", sample=SAMPLES),
        bai = expand("sorted_reads/{sample}.bam.bai", sample=SAMPLES)

    output:
        "calls/all.vcf"
    shell:
        "samtools mpileup -g -f {input.fa} {input.bam} | "
        "bcftools call -mv - > {output}"


rule merge_variants:
    input:
        fa=config["genome"] + config["ext"],
        fai=config["genome"] + config["ext"] + ".fai",
        dict=config["genome"] + ".dict",
        vcf=expand("calls/{sample}.g.vcf",sample=config["samples"]),
    output:
        temp("calls/merged_results.vcf")
    message: "Executing GATK CombineGVCFs with {threads} threads on the following files {input}."
    shell:
        "java -jar ./GATK/GenomeAnalysisTK.jar -T CombineGVCFs -R {input.fa} {vcf2} -o {output} "

