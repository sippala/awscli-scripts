#!/bin/bash
#set -x

if [[ $# -eq 0 ]] ; then
   echo 'run script with dev/qa/beta/prod as an argument'
   exit 1
else
   aws s3 ls --profile=$1 | cut -d ' ' -f 3 > s3_bucket_list_$1

   while read line ; do
      echo "Name: $line" >> s3_main_$1.json

      if JSON_STRING="$(aws s3api get-bucket-lifecycle-configuration --bucket "$line" --profile=$1)" ; then
         echo "Lifecycle Policy" >> s3_main_$1.json
         echo $JSON_STRING | python -m json.tool >> s3_main_$1.json
      else
         echo "No Lifecycle Policy" >> s3_main_$1.json
      fi

      if JSON_STRING="$(aws s3api get-bucket-policy --bucket "$line" --output text --profile=$1)" ; then
         echo "Bucket Policy" >> s3_main_$1.json
         echo $JSON_STRING | python -m json.tool >> s3_main_$1.json
      else
         echo "No Bucket Policy" >> s3_main_$1.json
      fi

      VERSION_STRING="$(aws s3api get-bucket-versioning --bucket "$line" --profile=$1)"
      if [ -z "$VERSION_STRING" ] ; then
         echo "Versioning not enabled" >> s3_main_$1.json
      else
         echo "Versioning" >> s3_main_$1.json
         echo $VERSION_STRING | python -m json.tool >> s3_main_$1.json
      fi

      echo " " >> s3_main_$1.json
   done < s3_bucket_list_$1
fi
