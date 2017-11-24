#!/bin/sh
 
usage() { 
    echo "*******************************************************************************************************"
    echo "Usage: $0 [-c <num of days to keep the backup files>] [-d <directory for the files to rotate>]" 1>&2
    echo "Example: $0 -c 10 -d /tmp/dtr-backup-dir"
    echo "*******************************************************************************************************"
    exit 1
        }

while getopts ":c:d:" opt; do
  case $opt in 
    c)
       count=$OPTARG
       ;;
    d) 
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

#if ls $dtr_backup_dir/*.tar 1> /dev/null 2>&1; then
if ls $dtr_backup_dir/*-dtr-backup-*.tar 1> /dev/null 2>&1; then
  find $dtr_backup_dir -type f -name \*-dtr-backup-\*\.tar -mtime +$count -exec rm {} \; 2> $dtr_backup_dir/error_output_file
  if [ $? -ne 0 ]; then
    EMAIL_SUBJECT="Log rotation failed"
    /bin/mail -s $EMAIL_SUBJECT $EMAIL_RECIPIENTS $dtr_backup_dir/error_output_file
  fi
else
  EMAIL_SUBJECT= "There are no dtr-backup files found in the $dtr_backup_dir directory"
  /bin/mail -s $EMAIL_SUBJECT $EMAIL_RECIPIENTS 
fi
