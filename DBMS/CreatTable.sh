#!/bin/bash
shopt -s extglob
clear
TablePath="$1"
TableName="$2"
DBName="$3"
#---------------------------------------------------------------
#                      Add New Column Function
#---------------------------------------------------------------
function AddNewColumn {
	ColName=""
        ColType=""
	Header=$(head -n 1 "$TablePath")     #====  this Header has all columns of the table
        NewHeader=""

	while true
	do
		clear
		read -p " Enter Column Name:  " ColName
		if [ -z "$ColName" ] 
		then
			echo " Column name cannot be empty !!"
		else
			#=============================================
			if [[ "$ColName" == +([0-9]) ]]
                        then
                                echo " Column name cannot be numeric !!"
                        elif [[ "$ColName" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
                        then
                                if echo "$Header" | grep -q "$ColName("; then  #=== Search if the col is matched wit other or not
					echo "$ColName Column already exists inside $TableName Table !!"
				else
					break #=== The validation is true done :) now I have Valid ColName
				fi
			else
				echo " Invalid column name format !!"
                        fi
		fi
		sleep 2
	done
	#=======================================
	#      Select the Data type            
	#======================================
	while true
	do
		clear
		echo "===================================="
		echo "    Datatype For $ColName Column    "
		echo "===================================="
		echo "1) int"
		echo "2) float"
		echo "3) string"
		echo "4) char"
		echo "5) cancel the process :( "
		echo "===================================="
		read -p "Choose the Option Number : " Choise
		case $Choise in
			1) ColType="int"
				break
				;;
			2) ColType="float"
				break
				;;
			3) ColType="string"
				break
				;;
			4) ColType="char"
				break
				;;
			5) return 1
				;;
			*) echo "Invalid Option !! "
				;;
		esac
	done
	#=======================================
        #      Update the new column
        #=======================================
	NewHeader="${Header}${ColName}(${ColType}):" #=== the new columns in the table
	sed -i "1s/.*/$NewHeader/" "$TablePath"   # 1s first line only substitute .*/ => replace all line with the new header


	#========================================================================================================
        #   Update Existing Records : adding default value to the new col from the second line 2,$ from 2 the end
        #========================================================================================================
        if [ "$ColType" = "int" ]; then
                sed -i '2,$s/$/NULL:/' "$TablePath"

        elif [ "$ColType" = "float" ]; then
                sed -i '2,$s/$/NULL:/' "$TablePath"

        elif [ "$ColType" = "string" ]; then
                sed -i '2,$s/$/NULL:/' "$TablePath"

        elif [ "$ColType" = "char" ]; then
                sed -i '2,$s/$/NULL:/' "$TablePath"
        fi

	echo " Column $ColName ($ColType) added successfully :)"
        sleep 3
}

#---------------------------------------------------------------
#                            Set The PK
#---------------------------------------------------------------
echo "=========================== ( $DBName DB - $TableName Table ) ====="
echo "                                                                   "
while true
do
	read -p "Enter The PK Column Name Of ( $TableName Table ) :   " PKCOL
	if [ -z "$PKCOL" ]
	then
		echo "The PK can not be empty !! "
	else
		if [[ $PKCOL == +([0-9]) ]]
		then
			echo "The PK Name can not be numeric !! "
		elif [[ $PKCOL == +([A-Za-z]) ]]
		then
			echo "$PKCOL(int):" >> "$TablePath"
			echo "$PKCOL PK has been created in $TableName Table :) "
			sleep 3
			break
	       	fi
	fi
	sleep 2
	clear
	echo "=========================== ( $DBName DB - $TableName Table ) ====="
        echo "                                                                   "
done
clear
#--------------------------------------------------------------------------
#                              The Main Menu
#--------------------------------------------------------------------------
while true
do
	clear
	echo "=========================== ( $DBName DB - $TableName Table ) ====="
	echo "                                                                   "
	echo "============================="
	echo "1) Add New Column            "
	echo "2) Back                      "
	echo "============================="
	echo "                             "
	read -p " Enter The Option Number  " Choice
	case $Choice in
		1) clear
			AddNewColumn
			;;
		2) clear
			exit 1
			;;
		*) clear
			echo "Invalid Option !! "
			;;
	esac

done

