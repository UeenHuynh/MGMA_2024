import pandas as pd
from scipy.stats import kruskal

# Đọc dữ liệu từ file taxonomy.tsv cho long reads và short reads
long_reads = pd.read_csv('long_reads_taxonomy_exported/taxonomy.tsv', sep='\t')
short_reads = pd.read_csv('short_reads_taxonomy_exported/taxonomy.tsv', sep='\t')

# Lọc dữ liệu cho genus và species
long_genus = long_reads[long_reads['Taxon'].str.contains('g__')]['Feature ID'].value_counts()
short_genus = short_reads[short_reads['Taxon'].str.contains('g__')]['Feature ID'].value_counts()

long_species = long_reads[long_reads['Taxon'].str.contains('s__')]['Feature ID'].value_counts()
short_species = short_reads[short_reads['Taxon'].str.contains('s__')]['Feature ID'].value_counts()

# Tạo DataFrame cho genus
genus_df = pd.DataFrame({
    'Long Reads': long_genus,
    'Short Reads': short_genus
}).fillna(0)

# Thực hiện kiểm tra Kruskal-Wallis cho genus
H_stat_genus, p_value_genus = kruskal(genus_df['Long Reads'], genus_df['Short Reads'])

# Tạo DataFrame cho species
species_df = pd.DataFrame({
    'Long Reads': long_species,
    'Short Reads': short_species
}).fillna(0)

# Thực hiện kiểm tra Kruskal-Wallis cho species
H_stat_species, p_value_species = kruskal(species_df['Long Reads'], species_df['Short Reads'])

# Tạo bảng kết quả
results = pd.DataFrame({
    'Loại phân loại': ['Genus', 'Species'],
    'H-statistic': [H_stat_genus, H_stat_species],
    'p-value': [p_value_genus, p_value_species],
    'Kết luận': [
        'Không có sự khác biệt có ý nghĩa thống kê' if p_value_genus > 0.05 else 'Có sự khác biệt có ý nghĩa thống kê',
        'Không có sự khác biệt có ý nghĩa thống kê' if p_value_species > 0.05 else 'Có sự khác biệt có ý nghĩa thống kê'
    ]
})

# Lưu kết quả vào file CSV
results.to_csv('kruskal_wallis_results.csv', index=False)

print(results)
