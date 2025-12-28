#!/bin/bash
clear
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
#                      Update Data By PK Function
#--------------------------------------------------------------------------
function UpdateByPK {
	echo "==========================================="
        echo "  Update Data Into $TableName Table By PK  "
        echo "==========================================="
       	LinesCount=$(wc -l < "$TablePath")
        if [ "$LinesCount" -le 1 ]
	then
	    echo "There's no Data to update it !! :( "
	    sleep 3
	    clear
	    return 1
	fi
        Header=$(head -n 1 "$TablePath")
        IFS=':' read -ra Columns <<< "$Header"
	ColIndex=0
	GetPK=""
	for Col in "${Columns[@]}"
	do
		((ColIndex++))
		ColName=$(echo "$Col" | sed 's/(.*)//')
       		ColType=$(echo "$Col" | sed 's/.*(\(.*\))/\1/')
		if [ "$ColIndex" -eq 1 ]
		then
			while true
			do
				read -p "Which PK Value Want to Update For it [$ColName][$ColType] : " PK
				[ -z "$PK" ] && echo "PK value cannot be empty !!" && continue
				Type=$(CheckDataType "$PK")
				if [ "$Type" != "$ColType" ]
				then
					echo "Invalid Data Type !! Expected $ColType"
					continue
				fi
				if cut -d':' -f1 "$TablePath" | grep -qx "$PK"; then
					GetPK="$PK"
					break
				else
					echo "$PK Value in $ColName PK is not existed !!"
					continue
				fi
			done
		else
			OldValue=$(awk -F: -v pk="$GetPK" -v fn="$ColIndex" '$1==pk {print $fn}' "$TablePath")
			echo "Current value of [$ColName] = $OldValue"
			while true
       			 do
               			 read -p "Do you want to update [$ColName][$ColType] ? [Y/N] : " Choice
               			 if [ "$Choice" = "Y" ]; then

                       			 while true
                       			 do
                               			 read -p "Enter new value for [$ColName] : " NewValue
                               			 Type=$(CheckDataType "$NewValue")

                               			 if [ "$Type" != "$ColType" ]; then
                                       			 echo "Invalid Data Type !! Expected $ColType"
                                       			 continue
                               			 fi

                               			 LineNo=$(awk -F: -v pk="$GetPK" '$1==pk {print NR}' "$TablePath")
                               			 FieldNo=$ColIndex

         
                               			 awk -F: -v OFS=: -v ln="$LineNo" -v fn="$FieldNo" -v nv="$NewValue" '
                               			 NR==ln {$fn=nv} {print}
                               			 ' "$TablePath" > /tmp/tmpfile && mv /tmp/tmpfile "$TablePath"

                               			 echo "Column [$ColName] updated successfully :)"
                               			 break
                       			 done
                       			 break

               			elif [ "$Choice" = "N" ]; then
                       			 break
              			else
                       			 echo "Invalid Choice !! Please enter Y or N"
               			fi
       			 done
		fi
	done
}
#--------------------------------------------------------------------------
#               Update Data By Value Of Column Function
#--------------------------------------------------------------------------
function UpdateByColumn {
	echo "========================================================"
	echo "  Update Data Into $TableName Table By Value Of Column  "
	echo "========================================================"
	echo "                                                        "
	ListColumnsTable
	echo "                                                        "
       	LinesCount=$(wc -l < "$TablePath")
        if [ "$LinesCount" -le 1 ]
	then
	    echo "There's no Data to update it !! :( "
	    sleep 3
	    clear
	    return 1
	fi
	read -p "Enter The Column Name  :  " ColName
	if [ -z "$ColName" ]
	then
		echo "Column Name cannot be empty !! "
		return 1
	fi
	FiledNumber=0
	FoundAny=0
	Header=$(head -n 1 "$TablePath")
        IFS=':' read -ra Columns <<< "$Header"
	for Col in "${ColumnNamesClean[@]}" 
	do
		((FiledNumber++))
		if [ "$Col" = "$ColName" ]
		then
			if [ "$FiledNumber" -eq 1 ] 
			then
				echo "you cannot Change the PK !! :( "
				return 1
			else
				FoundAny=1
				break
			fi
		fi	
	done
	if [ "$FoundAny" -eq 0 ]
	then
		echo "$ColName Not existed in $TableName Table !! "
		return 1
	fi
	FullColName="${Columns[FiledNumber-1]}"
	ColName=$(echo "$FullColName" | sed 's/(.*)//')
        ColType=$(echo "$FullColName" | sed 's/.*(\(.*\))/\1/')
	clear
	echo "========================================================"
        echo "  Update Data Into $TableName Table By Value Of Column  "
        echo "========================================================"
        echo "                                                        "
	while true
	do
		read -p "Enter the old value in [$ColName][$ColType] Column :  " OldValue
		type=$(CheckDataType "$OldValue")
		if [ "$type" = "$ColType" ]
		then
			break
		else
			  echo "Invalid Data Type !! Expected $ColType"
                   	  continue
		fi	
	done
	while true 
	do
		read -p "Enter the New value in [$ColName][$ColType] Column :  " NewValue
                type=$(CheckDataType "$NewValue")
                if [ "$type" = "$ColType" ]
                then
                        break
                else
                          echo "Invalid Data Type !! Expected $ColType"
                          continue
                fi

	done
	
    # ================= Check Existence =================
    if ! awk -F: -v col="$FiledNumber" -v old="$OldValue" '
        NR>1 && $col==old {found=1}
        END {exit !found}
    ' "$TablePath"
    then
        echo "Value not found in column !!"
        return 1
    fi

    # ================= Update =================
    awk -F: -v OFS=: -v col="$FiledNumber" -v old="$OldValue" -v new="$NewValue" '
        NR==1 {print; next}
        $col==old {$col=new}
        {print}
    ' "$TablePath" > /tmp/tmpfile && mv /tmp/tmpfile "$TablePath"

    echo "Column [$ColName] updated successfully :)"
}
#--------------------------------------------------------------------------
#                         Show Table Function
#--------------------------------------------------------------------------
function ShowTable {
	cat "$TablePath" | column -t -s ":"
        read -p "Press Enter to continue..."
}
#--------------------------------------------------------------------------
#                              The Main Menu
#--------------------------------------------------------------------------
while true
do
	echo "==== Updating Page ========= ( $DBName DB - $TableName Table ) ====="
	echo "======================================"
	echo "1) Update Data By PK                  "
	echo "2) Update Data By Value Of Column     "
	echo "3) List Columns Of $TableName Table   "
	echo "4) Show The Table                     "
	echo "5) Back                     	    "
	echo "======================================"
	echo "                                      "
	read -p " Enter The Option Number  " Choice
	case $Choice in
		1) clear
			UpdateByPK
			;;
		2) clear
			UpdateByColumn
			;;
		3) clear
			ListColumnsTable
			;;
		4) clear
			ShowTable
			;;
		5) clear
			exit 1
			;;
		*) clear
			echo "Invalid Option"
			;;
	esac

done
