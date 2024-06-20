# Genome annotation and Pathway Analysis

- :calendar: *June 20th 2024*

---

## Table of contents

- [Genome annotation and Pathway Analysis](#genome-annotation-and-pathway-analysis)
  - [Table of contents](#table-of-contents)
  - [Genome annotation with Prokka](#genome-annotation-with-prokka)
  - [Quality control with QUAST](#quality-control-with-quast)
  - [Filter AMR-related genes](#filter-amr-related-genes)
  - [Double check queried AMR protein sequences](#double-check-queried-amr-protein-sequences)
  - [Pathway analysis for *Mycobacterium tuberculosis*](#pathway-analysis-for-mycobacterium-tuberculosis)

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

## Pathway analysis for ***Mycobacterium tuberculosis***

- Access my custom `gProfiler` pathway database for ***M.tuberculosis*** using the provided `token` to identify pathways associated with specific genes of interest.
- [gProfiler](https://biit.cs.ut.ee/) webpage.
