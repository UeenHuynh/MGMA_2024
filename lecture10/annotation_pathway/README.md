# Genome annotation and Pathway Analysis

- :calendar: *June 20th 2024*

---

## Genome annotation with Prokka

```bash
# https://www.ncbi.nlm.nih.gov/nuccore/NC_000962.3
mkdir -p "./prokka"
prokka \
    --genus "Mycobacterium" --species "Mycobacterium tuberculosis" --strain "H37Rv" \
    --rfam \
    --usegenus \
    --proteins "./NC_000962.3.gb" \
    --cpus 2 \
    --prefix "SRR28714678" \
    --outdir "./prokka" \
    "./unicycler/SRR28714678_assembly.fasta"
```

## Quality control with QUAST

```bash
quast \
    --output-dir "./quast/" \
    --features "prokka/SRR28714678.gff" \
    --threads 4 \
    -1 "trimmed/SRR28714678_1.trimmed.fastq.gz" -2 "trimmed/SRR28714678_2.trimmed.fastq.gz" \
    --single "trimmed/SRR28714678_unpaired.fastq.gz" \
    --glimmer \
    "unicycler/SRR28714678_assembly.fasta"
```

## Filter AMR-related genes

```bash
grep -iwE "blaC|erm|aac" prokka/SRR28714678.tsv | cut -f 1 > AMR/AMR_list.txt
seqtk subseq prokka/SRR28714678.faa AMR/AMR_list.txt  > "AMR/AMR_prots.fa"
```

## Double check queried AMR protein sequences

- Using `NCBI BLAST` on [these sequences](./AMR/AMR_prots.fa).

## Pathway analysis

- Access my custom `gProfiler` pathway database for ***Mycobacterium tuberculosis*** using the provided `token` to identify pathways associated with specific genes of interest.
- [gProfiler](https://biit.cs.ut.ee/) webpage.
