#!/bin/bash
DBPath="$1/$2"
DBName=$2

#----------------------------------------------------------------
#                     Helper Functions
#----------------------------------------------------------------

#= 1) Check Table Existing Status Function
function TableIsFound {
	TableName="$1" #=== Takes the Name of the table
	if [ -z "$TableName" ] 
	then
		return 1  #=== Empty name break the function and return 1
	else
		for Table in "$DBPath"/*
		do
			if [ -f "$Table" ] && [ "$(basename "$Table")" = "$TableName" ]
			then
				return 0 #=== Table is existed break the function and return 0
				
			fi
		done
	fi
	return 1 #=== Table is not Existed break the function and return 1
}

#----------------------------------------------------------------
#                   Create Table Function
#----------------------------------------------------------------
function CreateTable {
	echo " ----------------------      "
	read -p " Enter The Table Name :   " TableName
	echo " ----------------------      "
	[ -z "$TableName" ] && echo " Table name cannot be empty :(" && sleep 2 && clear && return 1 # Can not accept the empty file
	if TableIsFound "$TableName"; then
		echo " ---------------------------------"
		echo " $TableName is not Accepted !!  :("
		echo " ---------------------------------"
		sleep 2
		clear
	else
		touch  "$DBPath/$TableName"
		echo " -------------------------------------------"
		echo " $TableName has been created successfully ;)"
		echo " -------------------------------------------"
		sleep 2
		clear
		# Open Create table Scipt file
		#---------------------------------
		./CreatTable.sh "$DBPath/$TableName" "$TableName" "$DBName"
	
	fi
}

#----------------------------------------------------------------
#                  List All Tables Function
#----------------------------------------------------------------
function ListAllTable {
	 echo "--------------------------------------"
	 echo "   Tables in Database: $DBName        "
	 echo "--------------------------------------"
	 Index=1
	 FoundAny=0
 	 for Table in "$DBPath"/*
 	 do
 		 if [ -f "$Table" ]
		 then
			 echo " $Index ) $(basename "$Table")"
			 ((Index++))
			 FoundAny=1
		 fi
 	 done
	 if [ "$FoundAny" -eq 0 ]
	 then
		  echo " No Tables Found   :( "
		  sleep 2
		  return 1
	 fi
	 sleep 2
	 return 0
}
#----------------------------------------------------------------
#                    Drop Table Function
#----------------------------------------------------------------
function DropTable {
	if ! ListAllTable; then
                echo " No Tables to Drop !!"
		sleep 2
                return 1
        fi
        echo " ----------------------------------- "
        read -p " Enter The Table Name to Drop it :   " TableName
        [ -z "$TableName" ] && echo " Table name cannot be empty :(" && sleep 2 && clear && return 1 # Can not accept the empty file
	if TableIsFound "$TableName"; then
		rm "$DBPath/$TableName"
		echo " $TableName has been dropped successfullly  :)"
                echo " ---------------------------------------------"
        else
		echo " $TableName Is Not Existed "
        fi
	sleep 2
	clear
}
#----------------------------------------------------------------
#               Inert Data into Table Function
#----------------------------------------------------------------
function InsertDataAtTable {
	if ! ListAllTable; then
                echo " No Tables to Insert Data Into !!"
                sleep 2
                return 1
        fi
	echo " ----------------------------------- "
        read -p " Enter The Table Name to Insert Data inside it :   " TableName
        [ -z "$TableName" ] && echo " Table name cannot be empty :(" && sleep 2 && clear && return 1 # Can not accept the empty file
	if TableIsFound "$TableName"; then
               
                echo " Now You Are Accessing $TableName Table  :)"
                sleep 2
		clear
		# Open Insert Data into table Scipt file
                #---------------------------------------------
                ./InsertDataInTable.sh "$DBPath/$TableName" "$TableName" "$DBName"

        else
                echo " $TableName Is Not Existed "
        fi
        sleep 2
        clear

}
#----------------------------------------------------------------
#              Update Data in a Table Function
#----------------------------------------------------------------
function UpdateDataAtTable {
        if ! ListAllTable; then
                echo " No Tables to Update Data Into !!"
                sleep 2
                return 1
        fi
        echo " ----------------------------------- "
        read -p " Enter The Table Name to Update Data inside it :   " TableName
        [ -z "$TableName" ] && echo " Table name cannot be empty :(" && sleep 2 && clear && return 1 # Can not accept the empty file
        if TableIsFound "$TableName"; then

                echo " Now You Are Accessing $TableName Table  :)"
                sleep 2
                clear
                # Open Update Data into table Scipt file
                #---------------------------------------------
                ./UpdateDataInTable.sh "$DBPath/$TableName" "$TableName" "$DBName"

        else
                echo " $TableName Is Not Existed "
        fi
        sleep 2
        clear
}

#----------------------------------------------------------------
#               Select From Table Function
#----------------------------------------------------------------
function SelectFromTable {
        if ! ListAllTable; then
                echo " No Tables to Retrive Data from it !!"
                sleep 2
                return 1
        fi
        echo " ----------------------------------- "
        read -p " Enter The Table Name to Retrive the Data from it :   " TableName
        [ -z "$TableName" ] && echo " Table name cannot be empty :(" && sleep 2 && clear && return 1 # Can not accept the empty file
        if TableIsFound "$TableName"; then

                echo " Now You Are Accessing $TableName Table  :)"
                sleep 2
                clear
                # Open Select Data from  table Scipt file
                #---------------------------------------------
                ./SelectDataFromTable.sh "$DBPath/$TableName" "$TableName" "$DBName"

        else
                echo " $TableName Is Not Existed "
        fi
        sleep 2
        clear
}

#----------------------------------------------------------------
#                Delete From Table Function
#----------------------------------------------------------------
function DeleteFromTable {
        if ! ListAllTable; then
                echo " No Tables to Delete Data from it !!"
                sleep 2
                return 1
        fi
        echo " ----------------------------------- "
        read -p " Enter The Table Name to Delete Data from it :   " TableName
        [ -z "$TableName" ] && echo " Table name cannot be empty :(" && sleep 2 && clear && return 1 # Can not accept the empty file
        if TableIsFound "$TableName"; then

                echo " Now You Are Accessing $TableName Table  :)"
                sleep 2
                clear
                # Open Delete Data from table Scipt file
                #---------------------------------------------
                ./DeleteDataFromTable.sh "$DBPath/$TableName" "$TableName" "$DBName"

        else
                echo " $TableName Is Not Existed "
        fi
        sleep 2
        clear
}

#----------------------------------------------------------------
#              Alter Structure Table Function
#----------------------------------------------------------------
function AlterTable {
        if ! ListAllTable; then
                echo " No Tables to Modify the Structure of it !!"
                sleep 2
                return 1
        fi
        echo " ----------------------------------- "
        read -p " Enter The Table Name to Modify it's Structure :   " TableName
        [ -z "$TableName" ] && echo " Table name cannot be empty :(" && sleep 2 && clear && return 1 # Can not accept the empty file
        if TableIsFound "$TableName"; then

                echo " Now You Are Accessing $TableName Table  :)"
                sleep 2
                clear
                # Open Alter table Scipt file
                #---------------------------------------------
                ./AlterStructureTable.sh "$DBPath/$TableName" "$TableName" "$DBName"

        else
                echo " $TableName Is Not Existed "
        fi
        sleep 2
        clear
}

#================================================================
#                     The User Menu
#================================================================
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
	echo "9 ) Back                                                     "
	echo "======================================================       "
	read -p "  Choose The Option Number  " Choice
	case $Choice in
		1) clear
			CreateTable
			;;
		2) clear
			ListAllTable
			;;
		3) clear
			DropTable
			;;
		4) clear
			InsertDataAtTable
			;;
		5) clear
			UpdateDataAtTable
			;;
		6) clear
			SelectFromTable
			;;
		7) clear
			DeleteFromTable
			;;
		8) clear
			AlterTable
			;;
		9) clear
		       	exit 1
			;;
		*) clear
		       	echo "Invalid Option"
			;;
	esac
done

