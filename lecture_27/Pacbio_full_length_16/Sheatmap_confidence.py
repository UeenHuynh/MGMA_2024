import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Đọc dữ liệu từ file taxonomy.tsv
short_reads = pd.read_csv('short_reads_taxonomy_exported/taxonomy.tsv', sep='\t')
long_reads = pd.read_csv('long_reads_taxonomy_exported/taxonomy.tsv', sep='\t')

# Kiểm tra kích thước dữ liệu đã đọc
print(f"Short Reads: {short_reads.shape[0]} rows, {short_reads.shape[1]} columns")
print(f"Long Reads: {long_reads.shape[0]} rows, {long_reads.shape[1]} columns")

# Giả định rằng taxon có định dạng 'Kingdom;Phylum;Class;Order;Family;Genus;Species'
# Lấy taxon ở cấp độ Genus hoặc Species và độ tin cậy
def extract_final_taxon(row):
    parts = row['Taxon'].split(';')
    if len(parts) >= 7:  # Đảm bảo có đủ phần tử
        return parts[-1], row['Confidence']  # Trả về Species và Confidence
    return None, None

# Áp dụng hàm extract_final_taxon cho cả hai bảng
short_reads['Final Taxon'], short_reads['Confidence'] = zip(*short_reads.apply(extract_final_taxon, axis=1))
long_reads['Final Taxon'], long_reads['Confidence'] = zip(*long_reads.apply(extract_final_taxon, axis=1))

# Tạo bảng dữ liệu cho heatmap
heatmap_data_short = short_reads.pivot_table(values='Confidence', index='Final Taxon', aggfunc='mean', fill_value=0)
heatmap_data_long = long_reads.pivot_table(values='Confidence', index='Final Taxon', aggfunc='mean', fill_value=0)

# Gộp hai bảng lại
heatmap_data = pd.concat([heatmap_data_short, heatmap_data_long], axis=1)
heatmap_data.columns = ['Short Reads', 'Long Reads']  # Đặt tên cho các cột

# Vẽ heatmap chỉ khi có dữ liệu
if not heatmap_data.empty:
    plt.figure(figsize=(12, 8))
    sns.heatmap(heatmap_data, cmap='viridis', annot=True, fmt='.2f', cbar_kws={'label': 'Confidence'})
    plt.title('Heatmap of Taxon Confidence for Long and Short Reads')
    plt.xlabel('Read Type')
    plt.ylabel('Final Taxon')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()
else:
    print("Không có dữ liệu để vẽ heatmap.")
