# :microscope: Microbial Genome Analysis 2024

- :calendar: *June 16th 2024*

---

## :bookmark_tabs: Table of contents

- [:microscope: Microbial Genome Analysis 2024](#microscope-microbial-genome-analysis-2024)
  - [Table of contents](#bookmark_tabs-table-of-contents)
  - [1. NCBI project](#1-ncbi-project)
  - [2. Raw data: Accession `PRJNA1098701`](#2-raw-data-accession-prjna1098701)
  - [3. Prepare reference genome: `Genome assembly ASM19595v2`](#3-prepare-reference-genome-genome-assembly-asm19595v2)
  - [4. Sample QC](#4-sample-qc)
  - [5. Read mapping](#5-read-mapping)
    - [5.1 Map to reference genome](#51-map-to-reference-genome)
    - [5.2. Bam processing](#52-bam-processing)
  - [6. Bam QC](#6-bam-qc)
    - [6.1 Overall alignment stats](#61-overall-alignment-stats)
    - [6.2 Coverage of read depth](#62-coverage-of-read-depth)
    - [6.3 Flagstats](#63-flagstats)
  - [7. Aggregate all QC stats through MultiQC](#7-aggregate-all-qc-stats-through-multiqc)

## Microbial WGS analysis: Upstream workflow

![upstream_workflow](https://github.com/UeenHuynh/MGMA_2024/blob/main/lecture9/9.1_Mapping/img/upstream_workflow.png)

## 1. NCBI project

- BioProject: [PRJNA1098701](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1098701/)
- Reference genome: [ASM19595v2](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/195/955/GCA_000195955.2_ASM19595v2/)
- Taxonomy: [*Mycobacterium tuberculosis H37Rv*](https://www.ncbi.nlm.nih.gov/datasets/taxonomy/83332/)

## 2. Raw data: Accession `PRJNA1098701`

```bash
# Genotype: CalA_resC6
wget -P ./raw/ ftp.sra.ebi.ac.uk/vol1/fastq/SRR287/078/SRR28714678/SRR28714678_{1,2}.fastq.gz
# Genotype: CalB_546_1
wget -P ./raw/ ftp.sra.ebi.ac.uk/vol1/fastq/SRR287/067/SRR28714667/SRR28714677_{1,2}.fastq.gz
```

## 3. Prepare reference genome: `Genome assembly ASM19595v2`

```bash
# Download reference genome
wget \
    "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/195/955/GCA_000195955.2_ASM19595v2/GCA_000195955.2_ASM19595v2_genomic.fna.gz" \
    -P "./ref/ASM19595v2/"
# Masking repeat regions
gzip -c -d "./ref/ASM19595v2/GCA_000195955.2_ASM19595v2_genomic.fna.gz" > "./ref/ASM19595v2/GCA_000195955.2_ASM19595v2.fasta"
## Comparisons among reference genome to identify genome repeat location
mkdir -p "ref/ASM19595v2/masked/"
nucmer \
    -p "./ref/masked/reference" \
    --maxmatch --nosimplify \
    "./ref/ASM19595v2/GCA_000195955.2_ASM19595v2.fasta" \
    "./ref/ASM19595v2/GCA_000195955.2_ASM19595v2.fasta"
## BED file locations to be masked
show-coords -r -T -H "ref/masked/reference.delta" > "ref/masked/reference.coords"
awk '{if ($1 != $3 && $2 != $4) print $0}' ref/masked/reference.coords > ref/masked/masked_ref_BEFORE_ORDER.bed
awk '{print $8"\t"$1"\t"$2}' ref/masked/masked_ref_BEFORE_ORDER.bed > "ref/masked/masked_ref.bed"
## Masking regions in the bed file
bedtools maskfasta \
    -fi "./ref/ASM19595v2/GCA_000195955.2_ASM19595v2.fasta" \
    -bed "./ref/masked/masked_ref.bed" \
    -fo "./ref/masked/masked_reference.fa"

# Indexing (.fai and .dict)
mkdir -p "./ref/fai/" "./ref/dict/"
samtools faidx \
    "./ref/masked/masked_reference.fa" \
    -o "ref/fai/masked_reference.fa.fai"
gatk CreateSequenceDictionary \
    -R "./ref/masked/masked_reference.fa" \
    -O "./ref/dict/masked_reference.dict"

# BWA indexing
mkdir -p "ref/BWAIndex/"
bwa index \
    -p "./ref/BWAIndex/reference" \
    "./ref/masked/masked_reference.fa"    
```

## 4. Sample QC

```bash
# Run FastQC
fastqc \
    --threads 4 \
    --memory 4096 \
    -o "./output/FastQC/" \
    "./raw/SRR28714678_1.fastq.gz" "./raw/SRR28714678_2.fastq.gz"

# Trimming
fastp \
    --in1 "raw/SRR28714678_1.fastq.gz" \
    --in2 "raw/SRR28714678_2.fastq.gz" \
    --out1 "./output/trimmed/SRR28714678_1.trimmed.fastq.gz" \
    --out2 "./output/trimmed/SRR28714678_2.trimmed.fastq.gz" \
    --json "./output/trimmed/SRR28714678.fastp.json" \
    --html "./output/trimmed/SRR28714678.fastp.html" \
    --thread 4 \
    --detect_adapter_for_pe \
    --overrepresentation_analysis \
    2>&1 | tee "./output/trimmed/SRR28714678.fastp.log"
```

## 5. Read mapping

### 5.1 Map to reference genome

```bash
# BWA mapping
bwa mem \
    -K 100000000 -Y -R "@RG\tID:HAWRWADXX.CalA_resC6.1\tPU:1\tSM:SRR28714678_CalA_resC6\tLB:CalA_resC6\tDS:lecture9/ref/masked/masked_reference.fa\tPL:ILLUMINA" \
    -t 4 \
    "ref/BWAIndex/reference" \
    "output/trimmed/SRR28714678_1.trimmed.fastq.gz" "output/trimmed/SRR28714678_2.trimmed.fastq.gz" \
    > "output/alignment/SRR28714678_aln.sam"

# Covert to BAM format and sorting
samtools sort \
    --threads 4 \
    -o "./output/alignment/SRR28714678_aln_sorted.bam" \
    "./output/alignment/SRR28714678_aln.sam"
rm "./output/alignment/SRR28714678_aln.sam"
```

### 5.2. Bam processing

- #### Mark duplicate

```bash
mkdir -p "./output/alignment/markduplicates/"
gatk --java-options "-Xmx4G" MarkDuplicates \
    --INPUT "./output/alignment/SRR28714678_aln_sorted.bam" \
    --OUTPUT "./output/alignment/markduplicates/SRR28714678_sorted_md.bam" \
    --METRICS_FILE "./output/alignment/markduplicates/SRR28714678_md.metrics" \
    --TMP_DIR "./output/alignment/markduplicates/" \
    --REFERENCE_SEQUENCE "./ref/masked/masked_reference.fa" \
    -REMOVE_DUPLICATES false \
    -VALIDATION_STRINGENCY LENIENT
```

- #### Clean bam file after mark duplicate

```bash
gatk --java-options "-Xmx4G" CleanSam \
    -I "output/alignment/markduplicates/SRR28714678_sorted_md.bam" \
    -O "output/alignment/markduplicates/SRR28714678_cleaned_md.bam"
```

- #### Ensuring all mate-pair information is in sync between each read and its mate pair

```bash
gatk --java-options "-Xmx4G" FixMateInformation \
    -I "output/alignment/markduplicates/SRR28714678_cleaned_md.bam" \
    -O "output/alignment/markduplicates/SRR28714678_fixmate_md.bam" \
    --VALIDATION_STRINGENCY LENIENT
mv "output/alignment/markduplicates/SRR28714678_fixmate_md.bam" "output/alignment/markduplicates/SRR28714678_final.bam"
```

- #### Indexing preprocessed bam

```bash
samtools index "output/alignment/markduplicates/SRR28714678_final.bam"
```

## 6. Bam QC

### 6.1 Overall alignment stats

```bash
mkdir -p "./output/alignment/stats/"
samtools stat \
    --threads 1 \
    --reference "./ref/masked/masked_reference.fa" \
    "output/alignment/markduplicates/SRR28714678_final.bam" \
    > "output/alignment/stats/SRR28714678_final.bam.stats"
```

### 6.2 Coverage of read depth

```bash
mosdepth \
    --threads 4 \
    --fasta "./ref/masked/masked_reference.fa" \
    -n --fast-mode --by 500 \
    "./output/alignment/stats/mosdepth/SRR28714678_final" \
    "output/alignment/markduplicates/SRR28714678_final.bam"

mkdir -p "output/alignment/stats/qualimap/"
qualimap bamqc \
    -bam "output/alignment/markduplicates/SRR28714678_final.bam" \
    -p non-strand-specific \
    --collect-overlap-pairs \
    -outdir "output/alignment/stats/qualimap/" \
    -nt 2

samtools coverage \
    "output/alignment/markduplicates/SRR28714678_final.bam" \
    > "./output/alignment/stats/SRR28714678_final_cov.stats"
```

### 6.3 Flagstats

```bash
samtools flagstats \
    "output/alignment/markduplicates/SRR28714678_final.bam" \
    > "./output/alignment/stats/SRR28714678_final.flagstats"
```

## 7. Aggregate all QC stats through MultiQC

```bash
mkdir -p "output/results/"
multiqc . -f --filename "output/results/microbial_WGS_multiqc_report.html"
```
