#!/bin/bash
shopt -s extglob
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
function CheckDataType {
	Value="$1"
	# Integer (e.g. 10, -5)
   	 if [[ "$Value" =~ ^-?[0-9]+$ ]]; then
       		 echo "int"
       		 return 0
   	 fi

   	 # Float (e.g. 10.5, -3.14)
   	 if [[ "$Value" =~ ^-?[0-9]+\.[0-9]+$ ]]; then
       		 echo "float"
       		 return 0
   	 fi

   	 # Char (single character)
	 if [[ "$Value" =~ ^.$ ]]; then
	        echo "char"
       	        return 0
   	 fi

   	 # Otherwise string
   	 echo "string"
   	 return 0		

}
#--------------------------------------------------------------------------
#              Insert Data into the Table Function
#--------------------------------------------------------------------------
function InsertData {
    echo "====================================="
    echo "  Insert Data Into $TableName Table  "
    echo "====================================="

    Header=$(head -n 1 "$TablePath")
    IFS=':' read -ra Columns <<< "$Header"

    RowData=""
    ColIndex=0

    for Col in "${Columns[@]}"
    do
        ((ColIndex++))
      	ColName=$(echo "$Col" | sed 's/(.*)//')
        ColType=$(echo "$Col" | sed 's/.*(\(.*\))/\1/')

        # ================= PRIMARY KEY =================
        if [ "$ColIndex" -eq 1 ]; then
            while true
            do
                read -p "Enter value for PRIMARY KEY [$ColName][$ColType] : " Data

                [ -z "$Data" ] && echo "PK cannot be empty !!" && continue

                Type=$(CheckDataType "$Data")
                if [ "$Type" != "$ColType" ]; then
                    echo "Invalid Data Type !! Expected $ColType"
                    continue
                fi

                # Check uniqueness (first column only)
                if cut -d':' -f1 "$TablePath" | grep -qx "$Data"; then
                    echo "Primary Key must be UNIQUE !!"
                    continue
                fi

                RowData="$Data"
                break
            done

        # ================= OTHER COLUMNS =================
        else
            while true
	    do
		    read -p "Insert data into [$ColName][$ColType] ? [Y/N] : " Choice

		    if [ "$Choice" = "Y" ]; then

			# loop لإدخال القيمة
			while true
			do
			    read -p "Enter value for $ColName : " Data

			    Type=$(CheckDataType "$Data")
			    if [ "$Type" != "$ColType" ]; then
				echo "Invalid Data Type !! Expected $ColType"
			    else
				RowData="$RowData:$Data"
				break 2 # break from all loops
			    fi
			done

		    elif [ "$Choice" = "N" ]; then
			RowData="$RowData:NULL"
			break

		    else
			echo "Invalid Choice !! Please enter Y or N"
			continue
		    fi
	   done

        fi
    done

    echo "$RowData:" >> "$TablePath"
    echo "Record inserted successfully :)"
}





#--------------------------------------------------------------------------
#                              The Main Menu
#--------------------------------------------------------------------------
while true 
do
	echo "=========================== ( $DBName DB - $TableName Table ) ====="
	echo "                                                                   "
	echo "======================================"
	echo "1) Insert Data into $TableName Table  "
	echo "2) List Columns of $TableName Table   "
	echo "3) Back                     	    "
	echo "======================================"
	echo "                                      "
	read -p " Enter The Option Number  " Choice
	case $Choice in
		1) clear
			InsertData
			;;
		2) clear
			ListColumnsTable
			;;
		3) clear 
			exit 1
			;;
		*) clear
			echo "Invalid Option"
			;;
	esac	

done
