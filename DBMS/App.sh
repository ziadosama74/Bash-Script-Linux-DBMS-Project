#!/bin/bash
#========= The Project Path
#--------------------------
ProjectPath="$HOME"/Bash-Script-Linux-DBMS-Project/DBMS
clear
# ---------------------------------------------------------------
#                     Create Database function
# ---------------------------------------------------------------
function CreateDB {
	read -p "Enter The Name Of New Database : " DBName
	if [ -z "$DBName" ]
	then
		echo "The Name of DB can not be empty ❗🙁"
		return 1 # ==== break the function
	fi
	for DB in "$ProjectPath"/*
	do
		if [ -d "$DB" ]
		then
		       	if [ "$(basename "$DB")" = "$DBName" ]
			then
				echo "$DBName this name can not be accepted ❌🙁"
				return 1 # =====> break the function  
		       	fi
		fi
	done
	mkdir -p "$ProjectPath/$DBName"
	echo "$DBName DB has been created successfully ✅😉"
}
# ---------------------------------------------------------------
#                     List All  Databases function
# ---------------------------------------------------------------
function ListAllDB {
	echo " ------------------------------------------------------"
	echo "               The Current Databases                   "
	echo " ------------------------------------------------------"
	Index=1
	FoundAny=1
	for DB in "$ProjectPath"/*
	do
		if [ -d "$DB" ]
		then
			echo "=== $Index ) 🗂️  $(basename "  $DB") "
			((Index++))
			FoundAny=0
		fi
	done
	if [ "$FoundAny" -eq 1 ]
	then
		echo "No Database Found ❗🙁"
	fi
	return $FoundAny
}
# ---------------------------------------------------------------
#                     Drop  Database function
# ---------------------------------------------------------------
function DropDB {
	CheckDoneOperation="F"
	 if ! ListAllDB; then
                echo "--------------------------------"
                echo "    The System has no DB ❗🙁   "
                echo "--------------------------------"
                return 1 # break the function
	 fi
         echo "--------------------------------"
	 read -p " Enter The Name Of DB to Drop it :   " DBName
	 echo "--------------------------------"
	 if [ -z "$DBName" ]
         then 
		 echo "The Name of DB can not be empty ❗🙁"
		 return 1
	 else
		 for DB in "$ProjectPath"/*
		 do
			 if [ -d "$DB" ] && [ "$(basename "$DB")" = "$DBName" ]
			 then
				 rm -r "$DB"
				 echo "== $DBName 🗂️  has been dropped successfully ✅😉"
				 CheckDoneOperation="T"
				 break
			 fi
		 done
			if [ "$CheckDoneOperation" = "F" ]
			then
				echo " --------------------------------------"
				echo " There Is NO DB With  $DBName Name ❗🙁"
				echo " --------------------------------------"
			fi
	  fi
}
# ---------------------------------------------------------------
#                  Connect to  Databases function
# ---------------------------------------------------------------
function ConnectDB {
	 CheckDoneOperation="F"
         if ! ListAllDB; then
                echo "--------------------------------"
                echo "    The System has no DB ❗🙁   "
                echo "--------------------------------"
                return 1 # break the function
         fi
	 echo "--------------------------------------------"
         read -p " Enter The Name Of DB to Connect with it :   " DBName
         echo "--------------------------------------------"
	 if [ -z "$DBName" ]
         then
                 echo "The Name of DB can not be empty ❗🙁"
                 return 1
         else
                 for DB in "$ProjectPath"/*
                 do
                         if [ -d "$DB" ] && [ "$(basename "$DB")" = "$DBName" ]
                         then
                                 echo "== $DBName DB has been actually Found ✅"
                                 CheckDoneOperation="T"
                                 break
                         fi
                 done
                        if [ "$CheckDoneOperation" = "F" ]
                        then
                                echo " -------------------------------------"
                                echo " There Is NO DB With  $DBName Name ❗🙁 "
                                echo " -------------------------------------"
			elif [ "$CheckDoneOperation" = "T" ] 
			then
				echo "== $DBName DB has been connected successfully 😉"
				sleep 2
				clear
				./MenuUser.sh "$ProjectPath" "$DBName"
                        fi
          fi
}

# ===============================================================
#                    Display The App
# ===============================================================
chars=(W E L C O M E " " T O " " O U R " " B A S H " " S C R I P T " " P R O J E C T 🐧" " D B M S  🗂️" " )
Names=(I M P L E M E N T E D " " B Y " "
Z I A D " " O S A M A 👷 " " "&" " "
Y O S S E F " " A M G A D   👷 " " )
echo -n "    "
for (( i=0 ; i<= 50 ; i++ ))
do
	echo -n "="
	sleep 0.03
done
echo " "
echo -n "       "
for ch in "${chars[@]}"
do
    echo -n "$ch"
    sleep 0.03
done
echo " "
echo -n "       "
for NA in "${Names[@]}"
do
    echo -n "$NA"
    sleep 0.03
done
echo " "
echo -n "    "
for (( i=0 ; i<= 50 ; i++ ))
do
	echo -n "="
	sleep 0.03
done
echo " "
# ===============================================================
#                     The Main Menu Of The App
# ===============================================================
while true
do
	echo " "
	echo "====================== APP Page📱 =="
        echo "1) Create Database"
        echo "2) List Databases"
        echo "3) Connect To Database"
        echo "4) Drop Database"
        echo "5) Exit"
        echo "==================================="
	read -p "  Choose The Option Number : " Choice
	echo "----------------------------"
	case $Choice in 
		1) clear
		       	CreateDB
			sleep 1
			;;
		2) clear
			ListAllDB
			sleep 1
			;;
		3) clear
			ConnectDB
			sleep 1
			;;
		4) clear
			DropDB
			sleep 1
			;;
		5) clear
			echo "Good Bye "
		       	for (( i=1 ; i<=3 ; i++ ))
			do
				echo "       🙁👋"
				sleep 1
			done
			exit 0
			;;
		*) clear
			echo " ===   Sorry Invalid Option ❌🙁"
			;;
	esac
done



