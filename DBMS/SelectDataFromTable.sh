#!/bin/bash
shopt -s extglob
clear
TablePath="$1"
TableName="$2"
DBName="$3"

#---------------------------------------------------------------
#                    Select Rows Function
#---------------------------------------------------------------
function SelectRows {
    while true; do
        clear
        echo "=========================== ( $DBName 🗂️  - $TableName Table  📋 ) ====="
        echo "1) Display All Rows"
        echo "2) Display Rows By Column Values"
        echo "3) Back"
        echo "====================================================================="
        read -p "Enter Option Number: " ChoiceRows

        case $ChoiceRows in
            1)
                clear
		echo "======================================"
        	echo "       $TableName Table Data    📋    "
        	echo "======================================"
                cat "$TablePath" | column -t -s ":"
                read -p "Press Enter to continue...😉"
                ;;
            2)
                clear
                Header=$(head -n 1 "$TablePath")
                Columns=()
                for col in $(echo "$Header" | tr ":" "\n"); do
                    Columns+=("$(echo "$col" | sed 's/(.*)//')")
                done

                echo "Available Columns: ${Columns[*]}"
                read -p "Enter column name to filter by: " filter_col
                read -p "Enter values separated by space: " -a filter_vals

                # Find column number
                ColNum=0
                for i in "${!Columns[@]}"; do
                    if [[ "${Columns[$i]}" == "$filter_col" ]]; then
                        ColNum=$((i+1))
                        break
                    fi
                done

                if [[ $ColNum -eq 0 ]]; then
                    echo "Column '$filter_col' not found ❗🙁"
                    read -p "Press Enter to continue...😉"
                    continue
                fi

                tmpfile=$(mktemp)
                echo "$Header" > "$tmpfile"
		echo "======================================"
        	echo "       $TableName Table Data    📋    "
        	echo "======================================"
                awk -F":" -v col="$ColNum" -v vals="${filter_vals[*]}" '
                BEGIN { split(vals, arr, " ") }
                NR>1 {
                    for (i in arr) {
                        if ($col == arr[i]) { print; break }
                    }
                }' "$TablePath" >> "$tmpfile"

                column -t -s ":" "$tmpfile"
                rm "$tmpfile"

                read -p "Press Enter to continue...😉"
                ;;
            3)
                break
                ;;
            *)
                echo "Invalid option ❌"
                sleep 2
                ;;
        esac
    done
}

#---------------------------------------------------------------
#                    Select Columns Function
#---------------------------------------------------------------
function SelectColumns {
    while true; do
        clear
        Header=$(head -n 1 "$TablePath")
        Columns=()
        for col in $(echo "$Header" | tr ":" "\n"); do
            Columns+=("$(echo "$col" | sed 's/(.*)//')")
        done

        echo "Available Columns  📊  : ${Columns[*]}"
        echo "Enter column names separated by space (or 'back' to return) :"
        read -a SelectedCols

        if [[ "${SelectedCols[0]}" == "back" ]]; then
            return
        fi

        ColIndices=()
        for user_col in "${SelectedCols[@]}"; do
            found=0
            for i in "${!Columns[@]}"; do
                if [[ "${Columns[$i],,}" == "${user_col,,}" ]]; then
                    ColIndices+=($((i+1)))
                    found=1
                    break
                fi
            done
            if [[ $found -eq 0 ]]; then
                echo "Column '$user_col' not found. ❗🙁"
            fi
        done

        if [[ ${#ColIndices[@]} -eq 0 ]]; then
            echo "No valid columns selected. Press Enter to try again. ❌🙁"
            read
            continue
        fi
	echo "======================================"
        echo "       $TableName Table Data    📋    "
        echo "======================================"

        {
            for idx in "${ColIndices[@]}"; do
                printf "%s:" "$(echo "$Header" | cut -d: -f$idx)"
            done
            echo
            tail -n +2 "$TablePath" | while IFS=: read -r -a row; do
                for idx in "${ColIndices[@]}"; do
                    printf "%s:" "${row[$((idx-1))]}"
                done
                echo
            done
        } | sed 's/:$//' | column -t -s ":"

        echo
        read -p "Press Enter to continue...😉"
        return
    done
}
#---------------------------------------------------------------
#                        Dispaly All Function
#---------------------------------------------------------------
function DisplayAll {
	   echo "======================================"
           echo "       $TableName Table Data    📋    "
           echo "======================================"

	   cat "$TablePath" | column -t -s ":"
           read -p "Press Enter to continue...😉"
}
#---------------------------------------------------------------
#                            Main Menu
#---------------------------------------------------------------
while true; do
    clear
    echo "=========================== ( $DBName 🗂️  - $TableName Table  📋 ) ====="
    echo "1) Select All Columns"
    echo "2) Select Specific Columns"
    echo "3) Select Rows"
    echo "4) Back"
    echo "====================================================================="
    read -p "Enter Option Number : " Choice
    case $Choice in
        1)
            clear
            DisplayAll
            ;;
        2) clear
            SelectColumns
            ;;
        3) clear
            SelectRows
            ;;
        4)
            clear
            break  # Exit main menu loop
            ;;
        *)
            clear
            echo "Invalid Option ❌"
            ;;
    esac
done
