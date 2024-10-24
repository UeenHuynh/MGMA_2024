import pandas as pd

# Đọc tệp taxonomy cho long và short reads
long_reads_taxonomy = pd.read_csv('long_reads_taxonomy_exported/taxonomy.tsv', sep='\t')
short_reads_taxonomy = pd.read_csv('short_reads_taxonomy_exported/taxonomy.tsv', sep='\t')

# Lọc các cấp độ genus và species
long_genus = long_reads_taxonomy[long_reads_taxonomy['Taxon'].str.contains('g__')]
short_genus = short_reads_taxonomy[short_reads_taxonomy['Taxon'].str.contains('g__')]

long_species = long_reads_taxonomy[long_reads_taxonomy['Taxon'].str.contains('s__')]
short_species = short_reads_taxonomy[short_reads_taxonomy['Taxon'].str.contains('s__')]

# Lưu kết quả vào các tệp CSV
long_genus.to_csv('long_genus.csv', index=False)
short_genus.to_csv('short_genus.csv', index=False)

long_species.to_csv('long_species.csv', index=False)
short_species.to_csv('short_species.csv', index=False)

# So sánh số lượng genus và species
long_genus_set = set(long_genus['Taxon'])
short_genus_set = set(short_genus['Taxon'])

long_species_set = set(long_species['Taxon'])
short_species_set = set(short_species['Taxon'])

# Đếm số lượng genus và species
print(f"Số lượng Genus từ long reads: {len(long_genus_set)}")
print(f"Số lượng Genus từ short reads: {len(short_genus_set)}")

print(f"Số lượng Species từ long reads: {len(long_species_set)}")
print(f"Số lượng Species từ short reads: {len(short_species_set)}")

# Tìm genus/species chung và riêng
common_genus = long_genus_set.intersection(short_genus_set)
unique_long_genus = long_genus_set.difference(short_genus_set)
unique_short_genus = short_genus_set.difference(long_genus_set)

common_species = long_species_set.intersection(short_species_set)
unique_long_species = long_species_set.difference(short_species_set)
unique_short_species = short_species_set.difference(long_species_set)

# In ra thông tin chi tiết
print(f"Genus chung: {common_genus}")
print(f"Genus duy nhất từ long reads: {unique_long_genus}")
print(f"Genus duy nhất từ short reads: {unique_short_genus}")

print(f"Species chung: {common_species}")
print(f"Species duy nhất từ long reads: {unique_long_species}")
print(f"Species duy nhất từ short reads: {unique_short_species}")
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib_venn import venn2

# Tạo heat map
heatmap_data = pd.DataFrame({
    'Long Reads': [len(long_genus_set), len(long_species_set)],
    'Short Reads': [len(short_genus_set), len(short_species_set)],
    'Common': [len(long_genus_set.intersection(short_genus_set)), len(long_species_set.intersection(short_species_set))]
}, index=['Genus', 'Species'])

# Vẽ heatmap
plt.figure(figsize=(8, 5))
sns.heatmap(heatmap_data, annot=True, cmap='coolwarm', cbar_kws={'label': 'Count'})
plt.title('Comparison of Genus and Species between Long and Short Reads')
plt.xlabel('Read Type')
plt.ylabel('Taxonomic Level')
plt.savefig('heatmap.png')  # Lưu biểu đồ
plt.close()  # Đóng biểu đồ

# Vẽ Venn diagram cho genus
plt.figure(figsize=(8, 5))
venn2([long_genus_set, short_genus_set], set_labels=('Long Reads', 'Short Reads'))
plt.title('Venn Diagram of Genus')
plt.savefig('venn_genus.png')  # Lưu biểu đồ
plt.close()  # Đóng biểu đồ

# Vẽ Venn diagram cho species
plt.figure(figsize=(8, 5))
venn2([long_species_set, short_species_set], set_labels=('Long Reads', 'Short Reads'))
plt.title('Venn Diagram of Species')
plt.savefig('venn_species.png')  # Lưu biểu đồ
plt.close()  # Đóng biểu đồ
