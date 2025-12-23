#!/bin/bash
TablePath="$1"
TableName="$2"
DBName="$3"
#---------------------------------------------------------------
#                      Helper Functions
#---------------------------------------------------------------
ColumnNamesClean=() #== Store the names of column without the Data type
function ListColumnsTable {
	Header=$(head -n 1 "$TablePath")        #====  this Header has all columns of the table
	IFS=':' read -ra Columns <<< "$Header"  #==== store each filed in array & remove (:)
	echo "=== Columns of $TableName Table ==="
	echo "                                   "
	Index=1
	ColumnNamesClean=()   #== reset global array
	for col in "${Columns[@]}"
	do
		# Remove everything from '(' to ')'
                ColName="${col%%(*}"
		# Store in global array
                ColumnNamesClean+=("$ColName")
		echo "Col $Index) $col"
		((Index++))
	done

}
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
                sed -i '2,$s/$/0:/' "$TablePath"

        elif [ "$ColType" = "float" ]; then
                sed -i '2,$s/$/0:/' "$TablePath"

        elif [ "$ColType" = "string" ]; then
                sed -i '2,$s/$/0:/' "$TablePath"

        elif [ "$ColType" = "char" ]; then
                sed -i '2,$s/$/0:/' "$TablePath"
        fi

	echo " Column $ColName ($ColType) added successfully :)"
        sleep 3
}
#---------------------------------------------------------------
#                      Drop Column Function
#---------------------------------------------------------------
function DropColumn {
	ListColumnsTable
	echo "=================================="
	read -p "Enter The Column Name to Drop it :   " ColName
	if [ -z "$ColName" ]
	then
		echo "Column Name Cannot be empty !!"
		sleep 2
		return 1
	else
		ColIndex=0
                Found=0
		for Col in "${ColumnNamesClean[@]}"
		do
			((ColIndex++))
			if [ "$Col" = "$ColName" ]
			then
				if [ "$ColIndex" -eq 1 ]
				then
					echo "You cannot drop the PK Colum ( $Col ) "
					return 1
				fi
				Found=1
				#here we will delete all filed in the file
				#Output Field Separator (OFS)
				#NF : Number of the coumlumn in the line
				awk -F: -v col="$ColIndex" '
                                BEGIN { OFS=":" } 
                                {
                                        for (i=1; i<=NF; i++) {
                                                if (i != col) {
                                                        printf "%s", $i
                                                        if (i < NF) printf OFS
                                                }
                                        }
                                        printf "\n"
                                }' "$TablePath" > "$TablePath.tmp" && mv "$TablePath.tmp" "$TablePath"
				echo "Column $ColName has been dropped successfully :)"
				sleep 3
				return 0
			fi
		done
	fi
	echo "$ColName Column is not Found in $TableName Table :("
	sleep 2
	return 1

}
#---------------------------------------------------------------
#                      Alter Column Function
#---------------------------------------------------------------
function AlterColumn {
        ListColumnsTable
        echo "=================================="
        read -p "Enter The Column Name to Alter it :   " ColName

        if [ -z "$ColName" ]; then
                echo "Column Name Cannot be empty !!"
                sleep 2
                return 1
        fi

        ColIndex=0
        for Col in "${ColumnNamesClean[@]}"
        do
                ((ColIndex++))

                if [ "$Col" = "$ColName" ]; then

                        # ===== PK Column =====
                        if [ "$ColIndex" -eq 1 ]; then
                                read -p "Enter the new name of $Col (PK) : " NewColName

                                if [ -z "$NewColName" ]; then
                                        echo " New column name cannot be empty !!"
                                        sleep 2
                                        return 1
                                fi

                                # replace only in first line (header)
                                sed -i "1s/\b$Col\b/$NewColName/" "$TablePath"

                                echo "The PK Column has been renamed from $Col to $NewColName successfully :)"
                                sleep 3
                                return 0
                        fi

                        # ===== Non-PK Column =====
                        read -p "Enter the new name of $Col : " NewColName

                        if [ -z "$NewColName" ]; then
                                echo " New column name cannot be empty !!"
                                sleep 2
                                return 1
                        fi

                        sed -i "1s/\b$Col\b/$NewColName/" "$TablePath"

                        echo "Column $Col has been renamed to $NewColName successfully :)"
                        sleep 3
                        return 0
                fi
        done

        echo "$ColName Column is not Found in $TableName Table :("
        sleep 2
        return 1
}
#--------------------------------------------------------------------------
#                              The Main Menu
#--------------------------------------------------------------------------
while true
do
	echo "=========================== ( $DBName DB - $TableName Table ) ====="
	echo "                                                                   "
	echo "==================================="
	echo "1) Add New Column                  "
	echo "2) Drop Column              	 "
	echo "3) Rename Column             	 "
	echo "4) List Columns of $TableName Table"
	echo "5) Back                     	 "
	echo "==================================="
	echo "                             "
	read -p " Enter The Option Number  " Choice
	case $Choice in
		1) clear
			AddNewColumn
			;;
		2) clear
			DropColumn
			;;
		3) clear
			AlterColumn
			;;
		4) clear
			ListColumnsTable
			;;
		5) clear
			exit 1
			;;
		*) clear
			echo "Invalid Option !! "
			;;
	esac

done
