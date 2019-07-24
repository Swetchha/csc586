#! /bin/bash

if [ $# -eq 0 ] ; then
    status=$?
    echo "Please provide correct arguments and options"
    echo "Usage: ./check_arg.sh [-i|-n] [USERS]"
    echo "        Options(optional): -i or -n for interactive or non-interactive execution"
    echo "        Arguments: list of user names"
    echo "        Every user name must match this regular expression: '^[a-z][a-z0-9_]*$'"
    echo -e "\n" $status

elif [[ ( $# -gt 1) && (( $1 = "-i" ) || ( $1 = "-n" )) ]]  ; then
    for i in "${@:2}" ; do
      if [[ $i =~ ^[a-z][a-z0-9_]*$ ]] ; then
         status=$?
         continue
      else
         status=$?
         echo "ERR: option after an argument or wrong argument or wrong option 2:" $i
         echo "Please provide correct arguments and options"
         echo "Usage: ./check_arg.sh [-i|-n] [USERS]"
         echo "       Options(optional): -i or -n for interactive or non-interactuve execution"
         echo "       Arguments: list of user names"
         echo "       Every user name must match this regular expression: '^[a-z][a-z0-9_]*$'"
         echo -e "\n" $status
         exit 1;
      fi
    done
    echo "Options and arguments okay"
    if [ $1 = "-n" ] ; then
       echo "running in NON-interactive mode"
    else
       echo "running in interactive mode"
    fi
    echo -e "\n" $status 

elif [ $# -ge 1 ] ; then
    for i in $@ ; do
       if [[ $i =~ ^[a-z][a-z0-9_]*$ ]] ; then
          status=$?
          continue
       else
          status=$?
          echo "ERR: option after an argument or wrong argument or wrong option 2:" $i
          echo "Please provide correct arguments and options"
          echo "Usage: ./check_arg.sh [-i|-n] [USERS]"
          echo "       Options(optional): -i or -n for interactive or non-interactuve execution"
          echo "       Arguments: list of user names"
          echo "       Every user name must match this regular expression: '^[a-z][a-z0-9_]*$'"
          echo -e "\n" $status
          exit 1;
       fi
    done
    echo "Options and arguments okay"
    echo "running in Interactive mode"
    echo -e "\n" $status
fi


