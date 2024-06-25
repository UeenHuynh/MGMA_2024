
# Download data
curl https://mothur.s3.us-east-2.amazonaws.com/data/MiSeqDevelopmentData/StabilityNoMetaG.tar -o StabilityNoMetaG.tar

tar -xvf StabilityNoMetaG.tar

# read per sample
for sample in `ls *.gz | cut -d "_" -f1 | uniq`; do
   n_read=`zcat ${sample}_*.gz | grep "^@M" | wc -l`;
   echo -e $sample '\t' $n_read;
done > ../out/n_read_per_sample.tsv

sort -nk2 ../out/read_count.tsv