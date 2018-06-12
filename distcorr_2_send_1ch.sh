#!/bin/sh

# This script zips and sends the required files to LDDMM (single channel) to generate a nonlinear transformation from the prepared b0 to the prepared t2 (see step 1)
# distcorr_2_send_1ch.sh
# Colleen's original script: T:\amri\DTIanalysis\fsl\scripts\setup_lddmm_send.sh
# Updated 20180612
# Christine L Kuryla

# Parameter 1: email address for lddmm 
# Run in a directory with:
# Template.img Template.hdr Target.img Target.hdr identity.txt LocalAddress.txt lddmm.conf

# Remote LDDMM Processing https://www.mristudio.org/wiki/programmer_manual/remote_processing
# Slicer JHU CIS LDDMM instructions: https://www.slicer.org/wiki/Slicer3:LDDMM#Register_.28free.21.29

# *********************************************************
# Start script
# *********************************************************

# link to lddmm output will be sent to this email address
myEmail=$1

# zip files together, generate md5 string, name appropriately

# zip required files together
zip tmp.zip Template.img Template.hdr Target.img Target.hdr identity.txt LocalAddress.txt lddmm.conf

#generate md5 string that corresponds to tmp.zip
md5=`md5sum tmp.zip | awk '{print $1}'`

# rename tmp.zip to the generated md5 string .zip (as required by lddmm)
mv tmp.zip ${md5}.zip


# ------------------------------------------------------------
# ----- log in and send to lddmm server via ftp 
# ------------------------------------------------------------

# lddmm server is ftp.mristudio.org
# name: anonymous
# password: Kuryla@kennedykrieger.org (or your email)

echo logging into ftp.mristudio.org
ftp ftp.mristudio.org

# !!!!!! need to figure out how to put in username and pw
# user $user $password (see lddmm instructions)
user anonymous ${myEmail}

echo changing directory and uploading ${md5}.zip
cd /pub/INCOMING/lddmm-volume/process-queue
put ${md5}.zip

# see clk evernote for more ideas
echo ${md5}.zip sent! Just wait for the email! 


# *********************************************************
# -----Resources----------
# *********************************************************

# ------------------------------------------------------------
# ----- Guidlines for LDDMM's requirements
# ------------------------------------------------------------

# Remote LDDMM Processing: https://www.mristudio.org/wiki/programmer_manual/remote_processing
# Slicer JHU CIS LDDMM instructions: https://www.slicer.org/wiki/Slicer3:LDDMM#Register_.28free.21.29

# ------------------------------------------------------------
# ----- sources of help
# ------------------------------------------------------------

# md5 info on the net:
# https://help.ubuntu.com/community/HowToMD5SUM
# https://www.howtoforge.com/linux-md5sum-command/
# md5 is basically a standardized algorithm to check whether two files are identical or not

# awk help:
# If you ever write a how-to article on the world wide web, please include a stock photo like so:
# https://www.lifewire.com/write-awk-commands-and-scripts-2200573 
# It will make the world a better place.
# Christine Daaé

# ftp in a script: 
# http://www.stratigery.com/scripting.ftp.html

