# List steps and status

# Starting place: T:\amri\DTIanalysis\Atlasbased_automation\atlasbased_auto_part3.sh

#!/bin/sh

s=$1
atlasdir=/mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS
eyemat=/mnt/dcn_data1/amri/DTIanalysis/scripts/eye.xfm
resamplemat=/mnt/dcn_data1/amri/DTIanalysis/scripts/resample.xfm
ident=buckless@kennedykrieger.org

echo retrieving multichannel LDDMM job
md5=$(cat multichan_LDDMM_input/zip_files_multi.txt)

mkdir Multichannel_LDDMM
cd Multichannel_LDDMM

get_lddmm_results_multi.sh

unzip -o Result.zip

cd ..

echo applying multi channel LDDMM to FA and  B0
lddmm-utils IMG_apply_lddmm_tform multichan_LDDMM_input/Target1.img Multichannel_LDDMM/Kimap.vtk ${s}_lddmm_fa_padded.img 1

lddmm-utils IMG_apply_lddmm_tform multichan_LDDMM_input/Target2.img Multichannel_LDDMM/Kimap.vtk ${s}_lddmm_b0_padded.img 1

#unpadding lddmm FA and B0
flirt -in ${s}_lddmm_fa_padded.img -ref /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_B0_ss.img -applyxfm -init /mnt/dcn_data1/amri/DTIanalysis/scripts/unpad.xfm -out ${s}_lddmm_fa.img

flirt -in ${s}_lddmm_b0_padded.img -ref /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_B0_ss.img -applyxfm -init /mnt/dcn_data1/amri/DTIanalysis/scripts/unpad.xfm -out ${s}_lddmm_b0.img

#padding atlases
cp /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_wmpm_cortical_rois.hdr .
cp /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_wmpm_subcortical_rois.hdr .
cp /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/Frontal\ Lobe\ Atlas_Final/Frontal_Lobe_Atlas.hdr .

cp /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_wmpm_cortical_rois.img .
cp /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_wmpm_subcortical_rois.img .
cp /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/Frontal\ Lobe\ Atlas_Final/Frontal_Lobe_Atlas.img .


flirt -in JHU_MNI_SS_wmpm_cortical_rois.img -ref /mnt/dcn_data1/amri/DTIanalysis/scripts/3123_template_padded.img -applyxfm -init /mnt/dcn_data1/amri/DTIanalysis/scripts/pad.xfm -out JHU_MNI_SS_wmpm_cortical_rois_padded.img

flirt -in JHU_MNI_SS_wmpm_subcortical_rois.img -ref /mnt/dcn_data1/amri/DTIanalysis/scripts/3123_template_padded.img -applyxfm -init /mnt/dcn_data1/amri/DTIanalysis/scripts/pad.xfm -out JHU_MNI_SS_wmpm_subcortical_rois_padded.img

flirt -in Frontal_Lobe_Atlas.img -ref /mnt/dcn_data1/amri/DTIanalysis/scripts/3123_template_padded.img -applyxfm -init /mnt/dcn_data1/amri/DTIanalysis/scripts/pad.xfm -out Frontal_Lobe_Atlas_padded.img

#this needs work!!!!
echo applying reverse LDDMM to atlases

lddmm-utils IMG_apply_lddmm_tform JHU_MNI_SS_B0_ss_padded.img Multichannel_LDDMM/Hmap.vtk ${s}_reverse_lddmm_b0_padded.img 1

lddmm-utils IMG_apply_lddmm_tform /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_B0_ss_padded.img Multichannel_LDDMM/Hmap.vtk ${s}_reverse_lddmm_b0_padded.img 1

lddmm-utils IMG_apply_lddmm_tform /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_B0_ss_padded.img Multichannel_LDDMM/Hmap.vtk ${s}_reverse_lddmm_b0_padded.img 1

lddmm-utils IMG_apply_lddmm_tform /mnt/dcn_data1/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_wmpm_subcortical_rois_padded.img Multichannel_LDDMM/Hmap.vtk ${s}_reverse_lddmm_b0_padded.img 1
