# Comparison of taxonomic resolution ability between Full-length 16S rRNA gene (long reads) and 16S V3V4 gene (short reads)    
## Publication 
https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-024-10213-5
![image](https://github.com/user-attachments/assets/efb19b5b-0250-4512-a54e-826da2da901a)
## Data collection by SRA toolkit    
**1. Trace NCBI**  https://www.ncbi.nlm.nih.gov/bioproject/PRJNA933120    
**2. Create the directory contents long and short reads data**
```bash
mkdir -p 16S_analysis/input/Pacbio 16S_analysis/input/illumina    
```

**3. Download data**    
- 4 Ilumina feaces samples SRR23380954, SRR23380955, SRR23380956, SRR23380957    
- 4 Pacbio feaces samplesSRR23380883, SRR23380890, SRR23380891, SRR23380892
```bash
prefetch SRR23380954 SRR23380955 SRR23380956 SRR23380957 SRR23380883 SRR23380890 SRR23380891 SRR23380892
```

**4. Convert .SRA file into fastq flie**    
```bash
fasterq-dump --outdir /home/hp/16S_analysis/input/Illumina --split-files SRR23380954
fasterq-dump --outdir /home/hp/16S_analysis/input/Illumina --split-files SRR23380955
fasterq-dump --outdir /home/hp/16S_analysis/input/Illumina --split-files SRR23380956
fasterq-dump --outdir /home/hp/16S_analysis/input/Illumina --split-files SRR23380957
fasterq-dump --outdir /home/hp/16S_analysis/input/Pacbio --split-files SRR23380883
fasterq-dump --outdir /home/hp/16S_analysis/input/Pacbio --split-files SRR23380890
fasterq-dump --outdir /home/hp/16S_analysis/input/Pacbio --split-files SRR23380891
fasterq-dump --outdir /home/hp/16S_analysis/input/Pacbio --split-files SRR23380892
````

## QC downloaded samples and statistic with SEQKIT and CSVTK
**1. Install Seqkit**  
```bash
conda install -c bioconda seqkit
``` 
**2. Install csvtk**    
```bash
conda install -c bioconda csvtk    
```
**3. QC and statistics for Illumina samples**    
```bash
for file in /home/hp/16S_analysis/input/illumina/*.fastq; do
    sampleID=$(basename "$file" .fastq)
    seqkit fx2tab -j 8 -q --gc -l -H -n -i "$file" | \
    svtk mutate2 -t -n sample -e "\"$sampleID\"" > "/home/hp/16S_analysis/fastqc/illumina/${sampleID}.seqkit.readstats.tsv"
    seqkit stats -T -j 8 -a "$file" | \
    csvtk mutate2 -t -n sample -e "\"$sampleID\"" > "/home/hp/16S_analysis/fastqc/illumina/${sampleID}.seqkit.summarystats.tsv"
done
```
**4. QC and statistics for Pacbio samples**   
```bash
for file in /home/hp/16S_analysis/input/pacbio/*.fastq; do
    sampleID=$(basename "$file" .fastq)
    
    # Xử lý thống kê read với seqkit và csvtk
    seqkit fx2tab -j 8 -q --gc -l -H -n -i "$file" | \
    csvtk mutate2 -t -n sample -e "\"$sampleID\"" > "/home/hp/16S_analysis/fastqc/pacbio/${sampleID}.seqkit.readstats.tsv"
    # Xử lý thống kê tổng hợp với seqkit và csvtk
    seqkit stats -T -j 8 -a "$file" | \
    csvtk mutate2 -t -n sample -e "\"$sampleID\"" > "/home/hp/16S_analysis/fastqc/pacbio/${sampleID}.seqkit.summarystats.tsv"
done
```
## Long Reads 16S hifi Pacbio Data processing with QIIME 2   
### Import to QIIME 2
**1. Generate manifest file***
```bash
nano manifest1.csv
```
*plaintext of manifest.csv*
```bash
sample-id,absolute-filepath,direction
SRR23380883,/home/hp/16S_analysis/input/pacbio/processed_data/SRR23380883.fastq,forward
SRR23380890,/home/hp/16S_analysis/input/pacbio/processed_data/SRR23380890.fastq,forward
SRR23380891,/home/hp/16S_analysis/input/pacbio/processed_data/SRR23380891.fastq,forward
SRR23380892,/home/hp/16S_analysis/input/pacbio/processed_data/SRR23380892.fastq,forward
````
**2. Import data to QIIME2**
```bash
conda activate qiime2-amplicon-2024.5
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path manifest.csv \
  --output-path long_reads_demux1.qza \
  --input-format SingleEndFastqManifestPhred33
```
**3. Inspect the imported data**   
```bash
qiime demux summarize \
  --i-data long_reads_demux1.qza \
  --o-visualization long_reads_demux1.qzv
```

### Denoising with DADA2 plugin
```bash
qiime dada2 denoise-ccs \
  --i-demultiplexed-seqs long_reads_demux1.qza \
  --o-table dada2-ccs_table.qza \
  --o-representative-sequences dada2-ccs_rep.qza \
  --o-denoising-stats dada2-ccs_stats.qza \
  --p-min-len 1000 \
  --p-max-len 1600 \
  --p-max-ee 3 \
  --p-front 'AGRGTTYGATYMTGGCTCAG' \
  --p-adapter 'RGYTACCTTGTTACGACTT' \
  --p-n-threads 8
```

### Remove chimeric ASVs
```bash
qiime vsearch uchime-denovo \
  --i-table dada2-ccs_table.qza \
  --i-sequences dada2-ccs_rep.qza \
  --o-chimeras chimeras.qza \
  --o-nonchimeras nonchimeras.qza \
  --o-stats chimera-stats.qza
```

### Generate SILVA database   
**1. Download SILVA database**
```bash
wget https://data.qiime2.org/2022.2/common/silva-138-99-tax.qza
wget https://data.qiime2.org/2022.2/common/silva-138-99-seqs.qza
```

**Update scikit-learn to Match Classifier Version**
```bash
pip install scikit-learn==0.24.1
```
**2. Filtering Chimeric ASVs**
```bash
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-classifier.qza \
  --i-reads nonchimeras.qza \
  --p-confidence 0.97 \
  --o-classification taxonomy.vsearch.qza
```

**Visualize taxonomy table**
```bash
qiime metadata tabulate \
  --m-input-file taxonomy.vsearch.qza \
  --o-visualization taxonomy.vsearch.qzv
````

**3. Update feature table**
```bash
qiime feature-table filter-features \
  --i-table dada2-ccs_table.qza \
  --m-metadata-file taxonomy.vsearch.qza \
  --o-filtered-table filtered_table.qza
```

**4. Generate taxa barplot**
**4.1. Generate metadata file**
```bash
nano metadata1.tsv
```
*plaintext*
```bash
sample-id       group   read_type
SRR23380883     pacbio  long
SRR23380890     pacbio  long
SRR23380891     pacbio  long
SRR23380892     pacbio  long
```

**4.2. Generate taxa barplot**
```bash
qiime taxa barplot \
  --i-table filtered_table.qza \
  --i-taxonomy taxonomy.vsearch.qza \
  --m-metadata-file metadata1.tsv \
  --o-visualization long_reads_taxa-bar-plots.qzv
```

### Generate phylo tree
**1. Filtering non chimeric ASV**
```bash
qiime feature-table filter-seqs \
  --i-data dada2-ccs_rep.qza \
  --i-table long_reads_filtered_table.qza \
  --o-filtered-data no-chimera-rep-seqs.qza
```

**2. Generate phylo tree**
```bash
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences no-chimera-rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
```

**3. Visualize phylo tree**
```qiime tools export \
  --input-path rooted-tree.qza \
  --output-path exported-rooted-tree
```
*View with iTOL website https://itol.embl.de/*


### Generate rarefaction curve
```bash
qiime diversity alpha-rarefaction \
  --i-table long_reads_filtered_table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 8500 \
  --m-metadata-file metadata1.tsv \
  --o-visualization long_reads_alpha-rarefaction.qzv
```

## Short Reads 16S Illumina Data processing with QIIME 2   
```bash
cd 16S_analysis/input/illumina
```

### Primers removal
**1. create the output directory**
```bash
mkdir -p trimmed_and_filtered_data
```

**2. create primer.txt file**
```bash
nano primers.txt
```
*plaintext*
```bash
>Bakt_341F
TCGTCGGCAAGCGTCAAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG
>Bakt_805R
GTCTCGTGGGCTCGGAGATGTGTAATAAGAGACAGGACTACHVGGGTATCTAATCC
```

**4. create script for primer removal**
```bash
nano trim_and_remove_primers.sh
```

**5. Grant execution right and run the script**
```bash
chmod +x trim_and_remove_primers.sh
./trim_and_remove_primers.sh
```
**3. create manifest.csv file**
```bash
nano manifest.csv
```
*plaintext*
```bash
sample-id,absolute-filepath,direction
SRR23380954,/home/hp/16S_analysis/input/illumina/trimmed_and_filtered_data/SRR23380954_1.fastq.trimmed.fastq.gz,forward
SRR23380954,/home/hp/16S_analysis/input/illumina/trimmed_and_filtered_data/SRR23380954_2.fastq.trimmed.fastq.gz,reverse
SRR23380955,/home/hp/16S_analysis/input/illumina/trimmed_and_filtered_data/SRR23380955_1.fastq.trimmed.fastq.gz,forward
SRR23380955,/home/hp/16S_analysis/input/illumina/trimmed_and_filtered_data/SRR23380955_2.fastq.trimmed.fastq.gz,reverse
SRR23380956,/home/hp/16S_analysis/input/illumina/trimmed_and_filtered_data/SRR23380956_1.fastq.trimmed.fastq.gz,forward
SRR23380956,/home/hp/16S_analysis/input/illumina/trimmed_and_filtered_data/SRR23380956_2.fastq.trimmed.fastq.gz,reverse
SRR23380957,/home/hp/16S_analysis/input/illumina/trimmed_and_filtered_data/SRR23380957_1.fastq.trimmed.fastq.gz,forward
SRR23380957,/home/hp/16S_analysis/input/illumina/trimmed_and_filtered_data/SRR23380957_2.fastq.trimmed.fastq.gz,reverse
```

### 3. import data to QIIME2
```bash
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.csv \
  --output-path short_reads_demux.qza \
  --input-format PairedEndFastqManifestPhred33
```
###. inspect the imported data
```bash
qiime demux summarize \
  --i-data short_reads_demux.qza \
  --o-visualization short_reads_demux.qzv
```

### filter, trim and denoise with DADA2 plugin
```bash
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs short_reads_demux.qza \
  --p-trunc-len-f 280 \
  --p-trunc-len-r 200 \
  --p-max-ee-f 5 \
  --p-max-ee-r 5 \
  --p-trim-left-f 10 \
  --p-trim-left-r 10 \
  --o-table short_reads_table.qza \
  --o-representative-sequences rep-short_reads_seqs.qza \
  --o-denoising-stats denoising-short_reads_stats.qza
```
### Generate metadata file
```bash
nano manifest.tsv
```
*plaintext*
```bash
sample-id	group	read_type
SRR23380954	illumina_faeces	short
SRR23380955	illumina_faeces	short
SRR23380956	illumina_faeces	short
SRR23380957	illumina_faeces	short
```

### visualize featuretable
```bash
qiime feature-table summarize \
  --i-table short_reads_table.qza \
  --o-visualization short_reads_table_summary.qzv \
  --m-sample-metadata-file metadata.tsv
```
### remove ASV chimerics
```bash
qiime vsearch uchime-denovo \
  --i-sequences rep-short_reads_seqs.qza \
  --i-table short_reads_table.qza \
  --o-chimeras short_reads_chimeras.qza \
  --o-nonchimeras short_reads_nonchimeras.qza \
  --o-stats uchime-stats.qza
```

**Check removed ASV Chemeric**
```bash
qiime metadata tabulate \
  --m-input-file short_reads_nonchimeras.qza \
  --o-visualization short_reads_nonchimeras.qzv
```

### Generarte SILVA database
**1. Download silva-138-99**
```bash
wget https://data.qiime2.org/2022.2/common/silva-138-99-tax.qza
wget https://data.qiime2.org/2022.2/common/silva-138-99-seqs.qza
```

**2. Update scikit-learn to Match Classifier Version**
```bash
pip install scikit-learn==0.24.1
```

### Classify non chimeric ASVs
```bash
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-classifier.qza \
  --i-reads short_reads_nonchimeras.qza \
  --p-confidence 0.97 \
  --o-classification taxonomy.qza
```
### visualize the classified taxanomy
```bash
qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
```

### filtering non chimerics ASVs
```bash
qiime feature-table filter-seqs \
  --i-data rep-short_reads_seqs.qza \
  --i-table short_reads_filtered_table.qza \
  --o-filtered-data no-chimera-rep-seqs.qza
```
  
### update feature table
```bash
qiime feature-table filter-features \
  --i-table short_reads_table.qza \
  --m-metadata-file taxonomy.qza \
  --o-filtered-table short_reads_filtered_table.qza
```

### visualize filtered feauture table
```bash
qiime feature-table summarize \
  --i-table short_reads_filtered_table.qza \
  --o-visualization filtered-short-reads-table-summary.qzv \
  --m-sample-metadata-file metadata.tsv
```

### Generate taxa barplot
```bash
qiime taxa barplot \
  --i-table short_reads_filtered_table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization short_reads_taxa-bar-plots.qzv
```

### generate phylotree
```bash
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences no-chimera-rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
```
**visualize phylortree**
```bash
qiime tools export \
  --input-path rooted-tree.qza \
  --output-path exported-rooted-tree
```

### Analyse rarefaction curve
```bash
qiime diversity alpha-rarefaction \
  --i-table short_reads_filtered_table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 89619 \
  --m-metadata-file metadata.tsv \
  --o-visualization short_reads_alpha-rarefaction.qzv
```

## Merging 2 filtered feature table to analyse alpha and beta diversity
moving 2 filtered feature tables to a folder named **merged_featuretable**

### cd to the merged_featuretable**
```bash
cd merged_featuretable
```

### generate metadata file
```bash
nano metadata.tsv
```
*plaintext*
```bash
sample-id	group	 read_type
SRR23380883	pacbio	long
SRR23380890	pacbio	long
SRR23380891	pacbio	long
SRR23380892	pacbio	long
SRR23380954	illumina	short
SRR23380955	illumina	short
SRR23380956	illumina	short
SRR23380957 illumina	short
```

### merging 2 feature table
```bash
qiime feature-table merge \
  --i-tables short_reads_filtered_table.qza \
  --i-tables long_reads_filtered_table.qza \
  --o-merged-table merged_feature_table.qza
```
**Visualize the merged feature table to check**
```bash
qiime feature-table summarize \
  --i-table merged_feature_table.qza \
  --o-visualization merged_feature_table_summary.qzv \
  --m-sample-metadata-file metadata.tsv
```

### analyse alpha diversity 
# Calculate alpha diversity
```bash
qiime diversity alpha \
  --i-table merged_feature_table.qza \
  --p-metric shannon \
  --o-alpha-diversity alpha-diversity.qza
```

# Visualize alpha diversity
```bash
qiime metadata tabulate \
  --m-input-file alpha-diversity.qza \
  --o-visualization alpha-diversity.qzv
```

```bash
qiime diversity alpha-group-significance \
  --i-alpha-diversity alpha-diversity.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization alpha-diversity-significance.qzv
```

### Analysing beta diversity
```bash
qiime diversity beta \
  --i-table merged_feature_table.qza \
  --p-metric braycurtis \
  --o-distance-matrix beta-diversity.qza
```

**1. PCoA**
```bash
qiime diversity pcoa \
  --i-distance-matrix beta-diversity.qza \
  --o-pcoa pcoa-results.qza
```

**2. Visualize PCoA***
```bash
qiime emperor plot \
  --i-pcoa pcoa-results.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization pcoa-plot.qzv
```

**3. PERMANOVA (analyse groups differences)**
```bash
qiime diversity beta-group-significance \
  --i-distance-matrix beta-diversity.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column read_type \
  --p-method permanova \
  --o-visualization beta-group-significance.qzv
```

## Comparison the taxonomy classification resolution between long and short reads
### export taxonomy classification results from QIIME 2
**1. Making a directory containing the comparision results*
```bash
cd home/hp/16S_analysis/input
```
```bash
mkdir comparison_genus_species
```
**1. Export Long reads**
```bash
qiime tools export \
  --input-path home/hp16S_analysis/input/pacbio/taxonomy.vsearch.qza \
  --output-path long_reads_taxonomy_exported
```
**2. Export short reads**
```bash
qiime tools export \
  --input-path home/hp16S_analysis/input/illumina/taxonomy.qza \
  --output-path short_reads_taxonomy_exported
```

### Comparison of genus and species between long and short reads
**1. Generate the script for coparison the counted genus and species of long vs short reads**
***1.1.  =generate the script**
```bash
nano genus_species_analysis.py
```
// please find the script content in the file with same name along with this README.md    
**1.2. Run the scipt**
```bash
python genus_species_analysis.py
```

**2. Kruskal wallis analysis**    
***2.1. generate the script for Kruskal wallis analysis***
```bash
nano kruskal_test_taxon.py
```
// please find the script content in the file with same name  along with this README.md   
***2.2. Run the script***
```bash
python kruskal_test_taxon.py
```

### Assessment of the reliability of Taxonomy Classification for Long and Short Reads Through a Comparison of Confidence Scores for Final Taxa
***2.1. Generate the script for Kruskal wallis analysis***
```bash
nano heatmap_confidence.py
```
// please find the script content in the file with same name  along with this README.md    
***2.2. Run the script***
```bash
python heatmap_confidence.py // run the script
```

