# Finish distortion correction after single channel lddmm results are retrieved
# distcorr_4_finish_1ch.sh

# Colleen's starting script as of 20180605
# T:\amri\DTIanalysis\Atlasbased_automation\atlasbased_auto_part2.sh



#!/bin/sh

s=$1
atlasdir=/mnt/dcn_data/amri/DTIanalysis/Atlasbased/ATLAS
eyemat=~/scripts/eye.xfm
resamplemat=~/scripts/resample.xfm
ident=buckless@kennedykrieger.org

echo retrieving single channel LDDMM job
md5=$(cat 1chan_LDDMM_input/md5.txt)

mkdir Single_Channel_LDDMM
cd Single_Channel_LDDMM

get_lddmm_results.sh $md5

cd ..

echo applying single channel LDDMM to B0
lddmm-utils IMG_apply_lddmm_tform 1chan_LDDMM_input/Target.img Single_Channel_LDDMM/Kimap.vtk ${s}_distcorr_b0_padded.img 1

unpadding distortion corrected B0
flirt -in ${s}_distcorr_b0_padded.img -ref /mnt/dcn_data/amri/DTIanalysis/Atlasbased/ATLAS/JHU_MNI_SS_B0_ss.img -applyxfm -init ~/scripts/unpad.xfm -out ${s}_distcorr_b0.img

echo applying single channel LDDMM to tensors
scannertensor2slicetensor.sh ${s}_resampled_tensor.img

/mnt/dcn_data/amri/DTIanalysis/Atlasbased/auto_RN/scripts/maptensors ${s}_resampled_tensor.img_sliceorder Single_Channel_LDDMM/Hmap.vtk Single_Channel_LDDMM/Kimap.vtk maptensors_output 181 217 181 1 1 1

slicetensor2scannertensor.sh maptensors_output

mv maptensors_output_imageorder ${s}_distcorr_tensor.img
cp ${s}_resampled_tensor.hdr ${s}_distcorr_tensor.hdr

#generate distcorr fa, MD, AD, RD - this needs to be figured out!!!

echo affine registration of distcorr B0 to atlas B0
flirt -in ${s}_distcorr_b0.img -ref $atlasdir/JHU_MNI_SS_B0_ss.img -out ${s}_affine_b0.img -omat ${s}_affine.xfm

echo affine registration of distcorr tensor
flirt -in ${s}_distcorr_tensor.img -ref $atlasdir/JHU_MNI_SS_B0_ss.img -applyxfm -init ${s}_affine.xfm -out ${s}_distcorr_unadjusted_tensor.img

echo reorienting affine tensor
# need to create lnB0, fake outlier map, concatenate them (see makecaminodt.pl

reorient -trans ${s}_affine.xfm < ${s}_distcorr_unadjusted_caminoDT > ${s}_distcorr_caminoDT
