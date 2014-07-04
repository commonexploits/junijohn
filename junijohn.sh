#!/usr/bin/env bash
# Juniper config password extractor for John the Ripper
# Daniel Compton
# www.commonexploits.com
# contact@commexploits.com
# Twitter = @commonexploits
# 25/10/2013
# Tested on Bactrack 5 & Kali
# reads juniper firewall config files in text format.

# Script begins
#===============================================================================

VERSION="1.0"
clear
echo -e "\e[00;31m#############################################################\e[00m"
echo -e "JuniJohn Version $VERSION "
echo ""
echo -e "Juniper Firewall Password Hash Convertor For John The Ripper"
echo ""
echo "https://github.com/commonexploits/junijohn"
echo -e "\e[00;31m#############################################################\e[00m"
echo ""
echo -e "\e[1;31m-----------------------------------------------------------------------------------\e[00m"
echo -e "\e[01;31m[?]\e[00m Enter the location of the Juniper config file i.e /tmp/juniper.txt (tab to complete path)"
echo -e "\e[1;31m-----------------------------------------------------------------------------------\e[00m"
echo ""
read -e JFILEIN
echo ""


cat "$JFILEIN" >/dev/null 2>&1
 if [ $? = 1 ]
   then
     echo ""
     echo -e "\e[1;31m Sorry I can't read that file, check the path or format and try again!\e[00m"
     echo ""
     exit 1
fi

cat "$JFILEIN" |grep -e "set admin name" -e "set admin user" -e "set zone" >/dev/null 2>&1
if [ $? = 1 ]
	then
                echo ""
                echo -e "\e[01;31m[!]\e[00m This does not seem to be a Juniper config!"
                echo ""
                exit 1
        else
                echo ""
                echo -e "\e[01;32m[+]\e[00m Juniper config file found"
                echo ""
fi

#Extract hostname
HOSTNAME=$(cat "$JFILEIN" |grep hostname |awk '{print $NF}' |sed 's/^[ \t]*//' |sed 's/\r//')
echo ""
#Extract main admin name
MADMIN=$(cat "$JFILEIN" | grep "admin name" |cut -d '"' -f 2)
#Extract main admin hash
MHASH=$(cat "$JFILEIN" |grep "admin password" |cut -d '"' -f 2)
#format for John ripper
echo ""$MADMIN":"$MADMIN"$"$MHASH"" > "johnjuni-hashes-"$HOSTNAME".txt"

#look for additional admin user accounts
cat "$JFILEIN" |grep "admin user" | cut -d '"' -f 2 >/dev/null
if [ $? = 0 ]
	then
	JAUSER=$(cat "$JFILEIN" |grep "admin user" | cut -d '"' -f 2)
	for JAAUSER in $(echo "$JAUSER")
	do
	JAHASH=$(cat "$JFILEIN" |grep "$JAAUSER" | cut -d '"' -f 4)
	echo ""$JAAUSER":"$JAAUSER"$"$JAHASH"" >> "johnjuni-hashes-"$HOSTNAME".txt"
	done
fi
echo "These have been saved to "johnjuni-hashes-"$HOSTNAME".txt""
echo ""
echo "Just run john "johnjuni-hashes-"$HOSTNAME".txt""
echo ""
paste johnjuni-hashes-"$HOSTNAME".txt
echo ""
echo "These have been saved to "johnjuni-hashes-"$HOSTNAME".txt""
echo ""
echo "Just run john "johnjuni-hashes-"$HOSTNAME".txt""
