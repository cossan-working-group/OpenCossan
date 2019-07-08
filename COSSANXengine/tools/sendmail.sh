#!/bin/bash

#
# mail.sh
#
# 2008 - Mike Golvach - eggi@comcast.net
#
# Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License
#

if [ $# -ne 6 ]
then
 echo "Usage: $0 FromAdress ToAdress Domain MailServer MailText MailSubject"
 exit 1
fi

from=$1
to=$2
domain=$3
mailserver=$4
mailtext=$5
subject=$6

if [ ! -f $mailtext ]
then
 echo "Cannot find your mail text file.  Exiting..."
 exit 1
fi

exec 9<>/dev/tcp/$mailserver/25
echo "HELO $domain" >&9
read -r temp <&9
echo "$temp"
echo "Mail From: $from" >&9
read -r temp <&9
echo "$temp"
echo "Rcpt To: $to" >&9
read -r temp <&9
echo "$temp"
echo "Data" >&9
read -r temp <&9
echo "$temp"
echo "Subject: $subject" >&9
read -r temp <&9
echo "$temp"
cat $mailtext >&9
echo "." >&9
read -r temp <&9
echo "$temp"
echo "quit" >&9
read -r temp <&9
echo "$temp"
9>&-
9<&-
echo "All Done Sending Email. See above for errors"
exit 0
