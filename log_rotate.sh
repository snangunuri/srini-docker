#!/bin/sh
 
usage() { 
    echo "Usage: $0 [-c <num of days to keep the backup files>] [-d <directory for the files to rotate>]" 1>&2; exit 1; 
        }

while getopts ":c:d:" opt; do
  case $opt in 
    c)
       echo "$OPTARG was triggered"
       ;;
    d) 
       echo "directory is: $OPTARG"
       ;;
    *) 
      echo "invalid option"
      usage
       ;;
  esac
done
shift "$(($OPTIND -1))"

if [ -z "${s}"] || [ -z "{p}" ]; then
   usage
fi
