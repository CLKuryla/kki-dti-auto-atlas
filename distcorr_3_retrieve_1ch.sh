# Purpose of script is to retrieve the single channel lddmm results from the server
# Colleen's orginal script as of 20180612
# There are two scripts here.
# T:\amri\DTIanalysis\Atlasbased_automation\get_lddmm_results.sh

#!/usr/bin/expect -f

# Takes no parameters. Run in a directory with:
# Template.img Template.hdr Target.img Target.hdr identity.txt LocalAddress.txt lddmm.conf
# 
#!/bin/sh

# Takes one parameter, which is the md5 sum of the job you want to retrieve

md5=$1

ftp ftp.mristudio.org<<SCRIPT
cd /pub/OUTGOING/lddmm-volume/output/${md5}
pwd
get Result.zip
quit 
SCRIPT

mv Result.zip Single_Channel_LDDMM/Result.zip
cd Single_Channel_LDDMM
unzip -o Result.zip



#!/usr/bin/expect -f

# Takes no parameters. Run in a directory with:
# Template.img Template.hdr Target.img Target.hdr identity.txt LocalAddress.txt lddmm.conf
# 

set username anonymous
set password Kuryla@kennedykrieger.org

spawn ftp ftp.mristudio.org
expect "Name (ftp.mristudio.org:lnir):"
send "${username}\r"
expect "Password:"
send "${password}\r"
expect "ftp>"
send "cd pub/OUTGOING/lddmm-volume/output/${md5}\r"
expect "ftp>"
send "get Results.zip\r"
expect "ftp>"
send "quit\r" 


unzip -o Result.zip
