rule all:
    input:
        'temp/out.sai'



rule bwa_index:
    input:
        'reference.fa'
    output:
        touch('bwa_index.done')
    shell:
        "bwa index {input}"


rule bwa_allign1:
    input:
        check = "bwa_index.done",
        gen = 'reference.fa',
        reads = "reads.txt"
    output:
        "temp/out.sai"
    shell:
        "bwa aln -I -t 8 {input.gen} {input.reads} > {output}"