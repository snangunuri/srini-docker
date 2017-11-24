#!/bin/sh
#set -x
DTR_VERSION=2.4.0
UCP_URL=https://54.175.154.26:443
UCP_USERNAME=admin
UCP_PASSWORD=admin123
echo $REPLICA_ID
TODAY=`date +%Y%m%d`
HOSTNAME=`hostname`
EMAIL_RECIPIENTS='srinivasa.nangunuri@aurotechcorp.com'
EMAIL_SUBJECT=''
REPLICA_ID=`docker ps -lf name='^/dtr' --format '{{.Names}}' | cut -d- -f3`
#email_function subject my_file
if [ ! -z "$REPLICA_ID" ];then
  docker run -i --rm docker/dtr:$DTR_VERSION backup \
     --ucp-url $UCP_URL --ucp-insecure-tls \
     --ucp-username $UCP_USERNAME --ucp-password $UCP_PASSWORD \
     --xxxexisting-replica-id $REPLICA_ID > /tmp/srini-docker/$HOSTNAME-dtr-backup-$TODAY.tar 2> error_output_file
  exit_status=$?
  if [ $exit_status -ne 0 ]; then
    EMAIL_SUBJECT="Exist status $exit_status is not equal to 0 from the backup script"
    echo $EMAIL_SUBJECT
    #/bin/mail -s $EMAIL_SUBJECT $EMAIL_RECIPIENTS  error_output_file
  fi
else
  EMAIL_SUBJECT="REPLICA_ID not found"   
fi

