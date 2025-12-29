#!/bin/bash
shopt -s extglob
clear

TablePath="$1"
TableName="$2"
DBName="$3"

#---------------------------------------------------------------
#                    Display All Rows Function
#---------------------------------------------------------------
function DisplayAll {
    echo "======================================"
    echo "       $TableName Table Data    📋    "
    echo "======================================"
    cat "$TablePath" | column -t -s ":"
    read -p "Press Enter to continue...😉"
}

#---------------------------------------------------------------
#                    Delete Rows Function
#---------------------------------------------------------------
function DeleteRows {
    while true; do
        clear
        echo "=========================== ( $DBName 🗂️  - $TableName Table  📋 ) ====="
        echo "1) Delete All Rows"
        echo "2) Delete Rows By Column Values"
        echo "3) Back"
        echo "====================================================================="
        read -p "Enter Option Number: " ChoiceDelete

        case $ChoiceDelete in
            1)
                clear
                Header=$(head -n 1 "$TablePath")
                echo "$Header" > "$TablePath"
                echo "All rows deleted successfully ✅😉"
                sleep 2
                ;;
            2)
                clear
                Header=$(head -n 1 "$TablePath")

                Columns=()
                for col in $(echo "$Header" | tr ":" "\n"); do
                    Columns+=("$(echo "$col" | sed 's/(.*)//')")
                done

                echo "Available Columns  📊  : ${Columns[*]}"
                read -p "Enter column name to delete by: " DelCol
                read -p "Enter values separated by space: " -a DelVals

                ColNum=0
                for i in "${!Columns[@]}"; do
                    if [[ "${Columns[$i]}" == "$DelCol" ]]; then
                        ColNum=$((i+1))
                        break
                    fi
                done

                if [[ $ColNum -eq 0 ]]; then
                    echo "Column '$DelCol' not found ❗🙁"
                    sleep 2
                    continue
                fi

                tmpfile=$(mktemp)
                echo "$Header" > "$tmpfile"

                awk -F":" -v col="$ColNum" -v vals="${DelVals[*]}" '
                BEGIN { split(vals, arr, " ") }
                NR>1 {
                    for (i in arr) {
                        if ($col == arr[i]) next
                    }
                    print
                }' "$TablePath" >> "$tmpfile"

                mv "$tmpfile" "$TablePath"
                echo "Rows deleted successfully ✅😉"
                sleep 2
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
#                            Main Menu
#---------------------------------------------------------------
while true; do
    clear
    echo "=========================== ( $DBName 🗂️  - $TableName Table  📋 ) ====="
    echo "1) Display Table"
    echo "2) Delete Rows"
    echo "3) Back"
    echo "====================================================================="
    read -p "Enter Option Number : " Choice

    case $Choice in
        1)
            clear
            DisplayAll
            ;;
        2)
            DeleteRows
            ;;
        3)
            clear
            break
            ;;
        *)
            clear
            echo "Invalid Option ❌"
            sleep 1
            ;;
    esac
done
