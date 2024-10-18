#!/bin/bash

declare -A dict_1=(
    [24-04794]="1LEU9_MNC_DNA"
    [24-04795]="2_P147_MNC_DNA"
    [24-04796]="3_LEU9_CD34_DNA"
    [24-04797]="4P147_CD34_DNA"
    [24-04798]="5ET_032600002_Dx_TWCs"
    [24-04799]="6QPF_032200001_Dx_TWCs"
    [24-04800]="70180_JH_Dx_MNCs"
    [24-04801]="8ET_12m_TWCs"
    [24-04802]="9QPF_12m_TWCs"
    [24-04803]="10ET_032600002_Dx_CD34"
    [24-04804]="11QPF_032200001_Dx_CD34"
    [24-04805]="120180_JH_Dx_CD34"
    [24-04806]="13RAP_ADE002_CD34"
    [24-04807]="14K562_Asc_sens_1"
    [24-04808]="15Asc_res_1"
    [24-04809]="SAGC_Negative"
)

echo "Beginning mapping files"

for key in "${!dict_1[@]}"; do
    echo "Key: $key, Value: ${dict_1[$key]}"
done

reference="$HOME/giab"
fastq_files_location="/mnt/e/SAGCQA1181/SAGC/fasta"
# fastq_files_test_location="$HOME/giab/fastaq"

# bwa-mem2 index "$reference"/hg38.fa

# gatk CreateSequenceDictionary -R "$reference"/hg38.fa -O "$reference"/hg38.dict

# Process each key in the dictionary
for key in "${!dict_1[@]}"; do
    # Use find to populate arrays
    r1_files=($(find ${fastq_files_location} -maxdepth 1 -name "${key}_S*_R1_*.fastq"))
    r2_files=($(find ${fastq_files_location} -maxdepth 1 -name "${key}_S*_R2_*.fastq"))

    # Check if files are found
    if [ ${#r1_files[@]} -eq 0 ] || [ ${#r2_files[@]} -eq 0 ]; then
        echo "No R1 or R2 files found for ID: $key" >> log.txt
        continue
    fi

    # Perform mapping and conversion
    echo "Working on ${dict_1[$key]}, output is ${dict_1[$key]}.bam" >> log.txt
    bwa-mem2 mem \
        -R "@RG\tID:$key\tSM:${dict_1[$key]}\tPL:ILLUMINA\tCN:SAGC" \
        -t 8 \
        "$reference"/hg38.fa \
        "${r1_files[@]}" \
        "${r2_files[@]}" \
        | samtools view -b \
        > output/full_genome_output/${dict_1[$key]}.bam

    # Log successful mapping
    echo "Successfully mapped files for ID: $key" >> log.txt
done

directory="$HOME/output/full_genome_output"
for bam_file in "$directory"/*; do
    if [ -f "$bam_file" ] && [[ "$bam_file" != *.bam.bai ]]; then
        bam_file_name=$(basename "$bam_file")
        bam_file_name="${bam_file_name%.bam}"
        echo Working on "$bam_file_name"

        # fixmate
        echo Running fixmate
        samtools fixmate -m -@ 8 \
        $directory/"$bam_file_name".bam \
        $directory/fixmate_output/"${bam_file_name}_fixmate.bam"

        # Markdup needs position order:
        echo Running Sort Position order
        samtools sort \
        $directory/"${bam_file_name}_fixmate.bam" \
        -o $directory/positionsort_output/"${bam_file_name}_pos_sort.bam"

        # Finally mark duplicates:
        echo Running mark dubplicates
        samtools markdup -@ 8 \
        $directory/positionsort_output/"${bam_file_name}_pos_sort.bam" \
        $directory/markdup_output/"${bam_file_name}_markdup.bam"
    fi
done



cd /home/cong_pham/giab
cd 
/home/cong_pham/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem "$reference" \
    -t 8 \
 "$fastq_files_test_location/2A1_CGATGT_L001_R1_001.fastq"\
  "$fastq_files_test_location/2A1_CGATGT_L001_R2_001.fastq"\
  | /home/cong_pham/bwa.kit/samtools view -b -t 8 \
  > out.bam



fileID="9QPF_12m_TWCs"
# samtools fixmate -m -@ 8 \
#     output/"$fileID".bam \
#     output/fixmate_output/"$fileID"_fixmate.bam
# samtools sort \
#     output/fixmate_output/"$fileID"_fixmate.bam \
#     -o output/positionsort_output/"$fileID"_pos_sort.bam
# samtools markdup -@ 8 \
#     output/positionsort_output/"$fileID"_pos_sort.bam \
#     output/markdup_output/"$fileID"_markdup.bam
samtools index output/markdup_output/"$fileID"_markdup.bam