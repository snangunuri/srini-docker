#!/bin/sh
 
usage() { 
    echo "Usage: $0 [-c <num of days to keep the backup files>] [-d <directory for the files to rotate>]" 1>&2
    echo "Example: $0 -c 10 -d /tmp/dtr-backup-dir"; exit 1
        }

while getopts ":c:d:" opt; do
  case $opt in 
    c)
       echo "$OPTARG was triggered"
       count=$OPTARG
       ;;
    d) 
       echo "directory is: $OPTARG"
       dtr_backup_dir=$OPTARG
       ;;
    *) 
      echo "invalid option"
      usage
       ;;
  esac
done
shift "$(($OPTIND -1))"

if [ -z "${count}" ] || [ -z "${dtr_backup_dir}" ]; then
   usage
fi

if ls $dtr_backup_dir/*.tar 1> /dev/null 2>&1; then
  find $dtr_backup_dir -type f -name \*\.tar -mtime +$count -exec rm {} \;
  if [ $? -eq 0 ]; then
    echo "Log rotation completed successfully"
  else
    echo "Log rotation failed, pleaes check"
  fi
else
  echo "There are no files found"
fi
