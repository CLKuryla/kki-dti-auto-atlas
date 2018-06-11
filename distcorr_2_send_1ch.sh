#!/bin/sh

# Colleen's original script

# Takes no parameters. Run in a directory with:
# Template.img Template.hdr Target.img Target.hdr identity.txt LocalAddress.txt lddmm.conf
# 
md5=$1

zip tmp.zip Template.img Template.hdr Target.img Target.hdr identity.txt LocalAddress.txt lddmm.conf


md5=`md5sum tmp.zip | awk '{print $1}'`

mv tmp.zip ${md5}.zip

ls>filelist

(egrep "*.zip" filelist)>zip_files.txt

#need to make file with only md5 in it, not done
(egrep "*.zip" zip_files.txt)>string_name.txt 

rm -rf filelist
