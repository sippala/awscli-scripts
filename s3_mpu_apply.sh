#!/bin/bash
buc=$1

if [[ $# -eq 0 ]] ; then
   echo 'ERROR : run script with bucketname and dev/qa/beta/prod as arguments'
   exit 1
else
  aws s3api get-bucket-lifecycle-configuration --bucket $buc  --profile=$2 > "$buc"_old_lifecycle
  LENGTH=`cat "$buc"_old_lifecycle | jq '.Rules |length'`
  LINES=`cat "$buc"_old_lifecycle | wc -l`
  echo "$buc rules -> $LENGTH and lines $LINES"

  if [ "$LINES" -gt "0" ]
  then
    cat "$buc"_old_lifecycle | jq '.Rules += [{  "Filter": {  "Prefix": ""  }, "Status": "Enabled",  "AbortIncompleteMultipartUpload": { "DaysAfterInitiation": 7 }, "Expiration": { "ExpiredObjectDeleteMarker": true }, "ID": "clean_mpu_and_deletemarker"  }]' > "$buc"_new_lifecycle

    aws s3api put-bucket-lifecycle-configuration --bucket $buc  --lifecycle-configuration file://"$buc"_new_lifecycle --profile=$2
    echo "$buc have existing rules appending mpu rule"
  else
    echo "$buc no existing rules apply mpu only rule"
    aws s3api put-bucket-lifecycle-configuration --bucket $1 --lifecycle-configuration file://mpu_policy.json --profile $2
  fi
fi
