#!/bin/bash
# Thiết lập số lõi CPU và tệp chứa các chuỗi primer
task_cpus=4
primers_file="primers.txt"  # Tệp chứa các chuỗi primer (mỗi primer trên một dòng)

# Thiết lập thư mục đầu vào và đầu ra
input_dir="processed_data"  # Thư mục chứa tệp FASTQ đã được lọc
output_dir="trimmed_and_filtered_data"  # Thư mục lưu tệp FASTQ đã trim và loại bỏ primer

# Xử lý tất cả các tệp FASTQ đã lọc trong thư mục đầu vào
for sampleFASTQ in "$input_dir"/*.filterQ*.fastq.gz; do
  # Lấy tên mẫu từ đường dẫn tệp
  sampleID=$(basename "$sampleFASTQ" .fastq.gz)

  # Trim và loại bỏ primer
  cutadapt -j $task_cpus \
           -g file:"$primers_file" \
           -o "$output_dir/${sampleID}.trimmed.fastq.gz" \
           "$sampleFASTQ"
done
