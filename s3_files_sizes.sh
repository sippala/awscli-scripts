#!/bin/bash
#set -x

word="$(echo $1 | head -c 1)"

if [[ $# -eq 0 ]] ; then
   echo 'run script with dev/qa/beta/prod as an argument'
   exit 1
else
        aws s3 ls --profile=$1 | cut -d ' ' -f 3 | grep "${word}-" > s3_bucket_list_$1

   while read line ; do
      echo "Name: $line" >> s3_main_$1.json

      aws s3 ls s3://"$line"/ --summarize --human-readable --recursive --profile="$1" >> s3_main_$1.json


      echo "------------------------------------------------------------------------- " >> s3_main_$1.json
   done < s3_bucket_list_$1
fi
