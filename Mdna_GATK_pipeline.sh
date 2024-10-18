#!/bin/bash
directory="$HOME/output/markdup_output"
for bam_file in "$directory"/*.bam; do
    if [ -f "$bam_file" ] && [[ "$bam_file" != *.bam.bai ]]; then
        bam_file_name=$(basename "$bam_file")
        bam_file_name="${bam_file_name%.bam}"
        gatk --java-options "-Xmx~{command_mem}m" Mutect2 \
            -R ~{ref_fasta} \
            -I ~{input_bam} \
            --read-filter MateOnSameContigOrNoMappedMateReadFilter \
            --read-filter MateUnmappedAndUnmappedReadFilter \
            -O ~{output_vcf} \
            ~{true='--bam-output bamout.bam' false='' make_bamout} \
            ~{m2_extra_args} \
            --annotation StrandBiasBySample \
            --mitochondria-mode \
            --max-reads-per-alignment-start ~{max_reads_per_alignment_start} \
            --max-mnp-distance 0

        gatk FilterMutectCalls \
            -R $HOME/giab/hg_38_mDNA.fasta \
            -V $HOME/output/VCF/"$bam_file_name".vcf.gz \
            -O $HOME/output/VCF/"$bam_file_name"_filtered.vcf.gz
        
        bcftools filter \
            -i 'FORMAT/AF >= 0.01' \
            -O z -o $HOME/output/VCF/"$bam_file_name"_filtered_1.vcf.gz $HOME/output/VCF/"$bam_file_name"_filtered.vcf.gz
    fi
done


# fileID="9QPF_12m_TWCs"
# gatk Mutect2 \
#     -R $HOME/giab/hg_38_mDNA.fasta \
#     -I $HOME/output/markdup_output/"$fileID"_markdup.bam \
#     -O $HOME/output/VCF/"$fileID"_markdup.vcf.gz \
#     --mitochondria-mode true \
#     --native-pair-hmm-threads 8
# gatk FilterMutectCalls \
#     -R $HOME/giab/hg_38_mDNA.fasta \
#     -V $HOME/output/VCF/"$fileID"_markdup.vcf.gz  \
#     -O $HOME/output/VCF/"$fileID"_markdup_filtered.vcf.gz
# bcftools filter \
#     -i 'FORMAT/AF >= 0.02' \
#     -O z -o $HOME/output/VCF/"$fileID"_markdup_filtered_1.vcf.gz $HOME/output/VCF/"$fileID"_markdup_filtered.vcf.gz