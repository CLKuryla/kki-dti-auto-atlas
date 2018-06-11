#!/bin/sh
# distcorr_1_prep_1ch.sh
# This script prepares b0 and t2 to send to llddmm for nonlinear distortion correction
# Step (II)
# Atlas-based automation, started by CB
# T:\amri\DTIanalysis\Atlasbased_automation\auto_atlas_clk\
# Christine L Kuryla
# 201806081523

# *********************************************************
# (I) Skull Stripping - incomplete
# (II) Distortion Correction - in progress
# (III) Linear (Affine) Registration: native to template (Mori or Ranta atlas)
# (IV) Non-linear Registration: native to template (atlas) - LDDMM
# (V) Reverse Transformations: atlas/wmpm to subject (native space)
#       # inverse of nonlinear composed with inverse of linear
# (VI) Generate stats
# *********************************************************

#Begin script for (II)
s=$1
atlasdir=/mnt/dcn_data/amri/DTIanalysis/Atlasbased/ATLAS
eyemat=~/scripts/eye.xfm
resamplemat=~/scripts/resample.xfm
ident=Kuryla@kennedykrieger.org
paddedtemplate=~/scripts/3123_template_padded.img
# Start with files:
#${s}_b0.hdr     #${s}_b0.img - same as dti_S0 from FSL
#${s}_t2.hdr     #${s}_t2.img     
#${s}_b0_ss.hdr  #${s}_b0_ss.img
#${s}_t2_ss.hdr  #${s}_t2_ss.img
#${s}_original_tensor.d

# *********************************************************
# (I) Skull Stripping - incomplete
# *********************************************************

# *********************************************************
# (II) DISTORTION CORRECTION - in progress
# Assume T2 is less distorted than b0, so align b0 to T2 via LDDMM
# This script prepares the b0 and T2 to send to LDDMM server
# Affine transformation not needed bc orientation should be same?????
# *********************************************************
# ------------------------------------------------------------
# ----- convert b0 and t2 to byte (so they play well with lddmm)
# ------------------------------------------------------------

# A byte (like unsigned char) has 256 unique values, so the intensities must be rescaled
echo converting b0 to byte...

# find max and min voxel intensity values, print to space-delimited text file
fslstats ${s}_b0_ss.img -R > ${s}_minmax_b0.txt

# assign max intensity (second entry in txt file) to a local variable
max_intensity_b0=$(awk -F" " '{print $2}' ${s}_minmax_b0.txt)

# divide by max to normalize image (intensities range: [0,1])
# multiply by 255 for desired range (intensities range: [0,255])
# convert to 8 bit data (char aka byte aka 8 bit aka 256 possible values)
# fslmaths ${s}_b0_ss.img -div $max_intensity_b0 -mul 255 ${s}_b0_ss_byte.img -odt char
fslmaths ${s}_b0_ss.img -div $max_intensity_b0 -mul 255 ${s}_b0_ss_byte.img -odt char

echo ${s} b0 is now byte :)

echo converting t2 to byte...

# same logic as b0 to byte conversion
fslstats ${s}_t2_ss.img -R > ${s}_minmax_t2.txt
max_intensity_t2=$(awk -F" " '{print $2}' ${s}_minmax_t2.txt)
fslmaths ${s}_t2_ss.img -div $max_intensity_t2 -mul 255 ${s}_t2_ss_byte.img -odt char
# next line will likely be deleted
# fslmaths ${s}_t2_ss.img -div $max_intensity_t2 -mul 255 ${s}_t2_ss_byte.nii.gz -odt char
echo ${s} t2 is now byte :)

# ------------------------------------------------------------
# ----- resample b0 and t2 to match mni space using flirt and the JHU_MNI_SS
# ---------------------------------------------------------------
echo resampling b0
flirt -in ${s}_b0_ss_byte.img -ref /mnt/dcn_data/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_B0_ss.img -applyxfm -init $resamplemat -out ${s}_resampled_b0

echo resampling t2
flirt -in ${s}_t2_ss_byte.img -ref /mnt/dcn_data/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_B0_ss.img -applyxfm -init $resamplemat -out ${s}_resampled_t2

# ------------------------------------------------------------
# ----- tensors......*** ???
# ----- convert tensors to analyze, flip orientation, skull strip
# ----- resample tensors using flirt
# ------------------------------------------------------------
echo converting tensor to analyze
cp dti_tensor.nii.gz dti_tensor.img
analyzeheader -initfromheader dti_S0.hdr -nimages 6 > dti_tensor.hdr
fslswapdim dti_tensor.img x -y z dti_tensor.img
echo skull-striping tensor
fslmaths dti_tensor.img -mas dti_S0.img ${s}_tensor_ss.img
echo resampling tensor
flirt -in dti_tensor.img -ref /mnt/dcn_data/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_B0_ss.img -applyxfm -init $resamplemat -out ${s}_resampled_tensor.img

# ------------------------------------------------------------
# ----- Package files for export to LDDMM single channel
# ----- ??
# ------------------------------------------------------------
echo packaging single channel LDDMM
mkdir 1chan_LDDMM_input
echo $ident > 1chan_LDDMM_input/identity.txt

# this has the settings/param that LDDMM needs to do its thang
cp ~/scripts/lddmm.conf_new_template.txt 1chan_LDDMM_input/lddmm.conf

# align b0 (target) to t2 (template)
echo Template > 1chan_LDDMM_input/LocalAddress.txt
echo ${PWD}/${s}_resampled_t2.img >> 1chan_LDDMM_input/LocalAddress.txt
echo Target >> 1chan_LDDMM_input/LocalAddress.txt
echo ${PWD}/${s}_resampled_b0.img >> 1chan_LDDMM_input/LocalAddress.txt

# fslmaths?!?!
fslmaths ${s}_resampled_byte_t2.img 1chan_LDDMM_input/Template
fslmaths ${s}_resampled_byte_b0.img 1chan_LDDMM_input/Target

# ------------------------------------------------------------
# ----- Pad t2 and b0, put results in lddmm input folder
# (lddm requires an even number of slices, but we have an odd number of slices, so we add an empty slice)
# ------------------------------------------------------------

flirt -in ${s}_resampled_byte_t2.img -ref $paddedtemplate -applyxfm -init ~/scripts/pad.xfm -out 1chan_LDDMM_input/Template.img
flirt -in ${s}_resampled_byte_b0.img -ref $paddedtemplate -applyxfm -init ~/scripts/pad.xfm -out 1chan_LDDMM_input/Target.img

# ------------------------------------------------------------
# ----- Send everything to lddmm server
# ------------------------------------------------------------
#sending LDDMM job
cd 1chan_LDDMM_input
send_lddmm_job.sh
cd ..
