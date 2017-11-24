#!/bin/sh
##########################################################################################
########This script takes dtr backup and rotates dtr-backup tar files ####################
##########################################################################################
DTR_VERSION=2.4.0
UCP_URL=https://54.175.154.26:443
UCP_USERNAME=admin
UCP_PASSWORD=admin123
echo $REPLICA_ID
TODAY=`date +%Y%m%d`
HOSTNAME=`hostname`
EMAIL_RECIPIENTS='srinivasa.nangunuri@aurotechcorp.com'
EMAIL_SUBJECT=''

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
      usage
       ;;
  esac
done
shift "$(($OPTIND -1))"

#######################################################################################################
####The following routine will rotate dtr-backup tar files with the given number of days to the script#
#######################################################################################################

if [ -z "${count}" ] || [ -z "${dtr_backup_dir}" ]; then
   usage
fi

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

####################################################################################################
####The following routine will run the dtr backup command and archive as tar files##################
####################################################################################################

REPLICA_ID=`docker ps -lf name='^/dtr' --format '{{.Names}}' | cut -d- -f3`
if [ ! -z "$REPLICA_ID" ];then
  docker run -i --rm docker/dtr:$DTR_VERSION backup \
     --ucp-url $UCP_URL --ucp-insecure-tls \
     --ucp-username $UCP_USERNAME --ucp-password $UCP_PASSWORD \
     --existing-replica-id $REPLICA_ID > $dtr_backup_dir/$HOSTNAME-dtr-backup-$TODAY.tar 2> $dtr_backup_dir/dtr_backup_output_file
  exit_status=$?
  if [ $exit_status -ne 0 ]; then
    EMAIL_SUBJECT="Exist status $exit_status is not equal to 0 from the backup script"
    echo $EMAIL_SUBJECT
    #/bin/mail -s $EMAIL_SUBJECT $EMAIL_RECIPIENTS  error_output_file
  fi
else
  EMAIL_SUBJECT="REPLICA_ID not found"
fi
