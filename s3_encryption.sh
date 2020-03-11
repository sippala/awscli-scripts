#!/bin/bash
#set -x

if [[ $# -eq 0 ]] ; then
   echo 'run script with dev/qa/beta/prod as an argument'
   exit 1
else
   aws s3 ls --profile=$1 | cut -d ' ' -f 3 > s3_bucket_list_$1

   while read line ; do
      echo "Name: $line" >> s3_encryption_$1.json

      if JSON_STRING="$(aws s3api get-bucket-encryption --bucket "$line" --profile=$1)" ; then
         echo "Encryption" >> s3_encryption_$1.json
         echo $JSON_STRING | python -m json.tool >> s3_encryption_$1.json
      else
       echo "No Encryption" >> s3_encryption_$1.json
      fi

      echo " " >> s3_encryption_$1.json
   done < s3_bucket_list_$1
fi

mv s3_encryption_$1.json s3_encryption_$1.txt
