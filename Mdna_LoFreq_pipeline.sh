#!/bin/bash

### LoFreq CALL/CALL-parallel: 
directory="$HOME/output/markdup_output"
# for bam_file in "$directory"/*.bam; do
#     if [ -f "$bam_file" ] && [[ "$bam_file" != *.bam.bai ]]; then
#         bam_file_name=$(basename "$bam_file")
#         bam_file_name="${bam_file_name%.bam}"
#         echo working on $bam_file_name at $bam_file

#         ref="$HOME/giab/hg_38_mDNA.fasta"
#         outfile="$HOME/output/VCF/lofreq_output/$bam_file_name.vcf"

#         lofreq call-parallel --pp-threads 8 \
#             -f "$ref" \
#             -o "$outfile" \
#             "$bam_file" \
#             --call-indels
#         echo $bam_file Job Done

#         # Compress the VCF  
#         bgzip "$outfile"
        
#         # Index the compressed VCF
#         tabix -p vcf "$outfile.gz"

#         bcftools filter \
#             -i 'INFO/AF >= 0.01' \
#             -O z -o "$HOME/output/VCF/lofreq_output/${bam_file_name}_filtered.vcf.gz" "$outfile.gz"
#         echo bcftool job done
#     fi
# done

### LoFreq CALL SOMATICS: 
ref="$HOME/giab/hg_38_mDNA.fasta"
# Case 1: 
tumor_file_5="$directory/5ET_032600002_Dx_TWCs_markdup.bam"
tumor_file_10="$directory/10ET_032600002_Dx_CD34_markdup.bam"
normal_file_8="$directory/8ET_12m_TWCs_markdup.bam"
# Case 2: 
tumor_file_6="$directory/6QPF_032200001_Dx_TWCs_markdup.bam"
tumor_file_11="$directory/11QPF_032200001_Dx_CD34_markdup.bam"
normal_file_9="$directory/9QPF_12m_TWCs_markdup.bam"


# Case 1: 
lofreq somatic -n $normal_file_8 -t $tumor_file_5 -f $ref --threads 8\
            -o "$HOME/output/VCF/lofreq_output/Somatics/normal_file_8vstumor_file_5"\
            --call-indels  
lofreq somatic -n $normal_file_8 -t $tumor_file_10 -f $ref --threads 8\
            -o "$HOME/output/VCF/lofreq_output/Somatics/normal_file_8vstumor_file_10"\
            --call-indels 

# Case 2: 
lofreq somatic -n $normal_file_9 -t $tumor_file_6 -f $ref --threads 8\
            -o "$HOME/output/VCF/lofreq_output/Somatics/normal_file_9vstumor_file_6"\
            --call-indels
lofreq somatic -n $normal_file_9 -t $tumor_file_11 -f $ref --threads 8\
            -o "$HOME/output/VCF/lofreq_output/Somatics/normal_file_9vstumor_file_11"\
            --call-indels