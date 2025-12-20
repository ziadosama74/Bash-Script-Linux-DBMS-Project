#!/bin/bash
DBPath="$1/$2"
DBName=$2
echo $DBPath
echo "----------------------------------------------"
echo "      Your Operation on $DBName DB            "
echo "=============================================="

#----------------------------------------------------------------
#                     The User Menu
#----------------------------------------------------------------
while true
do
	echo "================================ DB Page ( $DBName DB ) ==== "
	echo "1 ) Create New Table                                         "
	echo "2 ) List All Tables                                          "
	echo "3 ) Drop Table                                               "
	echo "4 ) Inert Data into Table                                    "
	echo "5 ) Update Data in a Table                                   "
	echo "6 ) Select From Table                                        "
	echo "7 ) Delete From Table                                        "
	echo "8 ) Alter Structure Table                                    "
	echo "9 ) Exit                                                     "
	echo "============================================================="
	read -p "  Choose The Option Number  " Choice
	echo "----------------------------"
	case $Choice in
		1) clear
			echo "Hello World"
			;;
		9) clear
		       	exit 1
			;;
		*) clear
		       	echo "Invalid Option"
			;;
	esac
done

