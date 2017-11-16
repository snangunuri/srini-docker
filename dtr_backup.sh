#!/bin/sh
DTR_VERSION=2.4.0
UCP_URL=https://54.175.154.26:443
UCP_USERNAME=admin
UCP_PASSWORD=admin123
echo $REPLICA_ID
TODAY=`date +%Y%m%d`
HOSTNAME=`hostname`
EMAIL_RECIPIENTS='srinivasa.nangunuri@aurotechcorp.com'
REPLICA_ID=`docker ps -lf name='^/dtr' --format '{{.Names}}' | cut -d- -f3`
email_function () {
  echo "checking the email $1"
  echo "example body" > /tmp/email_body.txt
  mail -s "example subject" $EMAIL_RECIPIENTS /tmp/email_body.txt
}
email_function srini
if [ ! -z "$REPLICA_ID" ];then
  docker run -i --rm docker/dtr:$DTR_VERSION backup \
     --ucp-url $UCP_URL --ucp-insecure-tls \
     --ucp-username $UCP_USERNAME --ucp-password $UCP_PASSWORD \
     --existing-replica-id $REPLICA_ID > /tmp/$HOSTNAME-dtr-backup-$TODAY.tar
  exit_status=$?
  if [ $exit_status -ne 0 ]; then
    echo "Exist status $exit_status is not equal to 0"
  fi
else
  echo "REPLICA_ID not found"   
fi

