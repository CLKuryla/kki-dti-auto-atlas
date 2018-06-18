
# Linear (affine) transformation from the distortion corrected subjects' native space to the standard space of the atlas 
# Generate the forward linear transformation using trilinear interpolation because it will be applied to the b0 and t2 (operationally continuous data)
# Generate the reverse linear transformation using nearest neighbor interpolation because it will be applied to the ROIs (WMPMs)

# for information about interpolation methods: 
# http://northstar-www.dartmouth.edu/doc/idl/html_6.2/Interpolation_Methods.html
# https://support.esri.com/en/technical-article/000005606
