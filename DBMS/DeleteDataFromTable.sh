
#!/bin/bash

TablePath="$1"
TableName="$2"
DBName="$3"


#---------------------------------------------------------------
#                Delete From Table Function
#---------------------------------------------------------------
function DeleteFromTable {

    while true
    do
        clear
        echo "==================== ( $DBName DB - $TableName Table ) ===================="
        echo "1) Display Table"
        echo "2) Delete All Rows"
        echo "3) Delete Rows By Column Value"
        echo "4) Back"
        echo "========================================================================="
        read -p "Choose Option : " Choice

        case $Choice in

        #-------------------------------------------------------
        # Display table
        #-------------------------------------------------------
        1)
            clear
            cat "$TablePath" | column -t -s ":"
            read -p "Press Enter to continue..."
            ;;

        #-------------------------------------------------------
        # Delete all rows (keep header)
        #-------------------------------------------------------
        2)
            clear
            Header=$(head -n 1 "$TablePath")
            echo "$Header" > "$TablePath"
            echo "All rows deleted successfully "
            sleep 2
            ;;

        #-------------------------------------------------------
        # Delete rows by column value
        #-------------------------------------------------------
        3)
             clear
         Header=$(head -n 1 "$TablePath")

    # Get column names
    Columns=()
    for col in $(echo "$Header" | tr ":" "\n"); do
        Columns+=("$(echo "$col" | sed 's/(.*)//')")
    done

    echo "Available Columns: ${Columns[*]}"
    read -p "Enter column name: " ColName
    read -p "Enter values to delete (space separated): " -a Values

    # Find column number
    ColNum=0
    for i in "${!Columns[@]}"; do
        if [[ "${Columns[$i]}" == "$ColName" ]]; then
            ColNum=$((i+1))
            break
        fi
    done

    if [[ $ColNum -eq 0 ]]; then
        echo "Column not found "
        sleep 2
        continue
    fi

    TempFile=$(mktemp)
    echo "$Header" > "$TempFile"

    Found=0

    awk -F":" -v col="$ColNum" -v vals="${Values[*]}" '
    BEGIN {
        split(vals, arr, " ")
    }
    NR>1 {
        for (i in arr) {
            if ($col == arr[i]) {
                found=1
                next
            }
        }
        print
    }
    END {
        if (found != 1) exit 10
    }
    ' "$TablePath" >> "$TempFile"

    if [[ $? -eq 10 ]]; then
        rm "$TempFile"
        echo "Value not found in column "
        sleep 2
        continue
    fi

    mv "$TempFile" "$TablePath"
    echo "Rows deleted successfully "
    sleep 2
    ;;
        #-------------------------------------------------------
        # Back
        #-------------------------------------------------------
        4)
            break
            ;;

        *)
            echo "Invalid Option "
            sleep 2
            ;;
        esac
    done
}

#---------------------------------------------------------------
#                       main === Start Delete Menu
#---------------------------------------------------------------
DeleteFromTable
