#!/bin/bash
#set -x

true > ~/s3_output_list_$1
word="$(echo $1 | head -c 1)"

if [[ $# -eq 0 ]] ; then
   echo 'run script with dev/qa/beta/prod as an argument'
   exit 1
else
   #aws s3 ls --profile=$1 | cut -d ' ' -f 3 | grep "${word}-" > s3_bucket_list_$1

   input="~/s3_selected_list_$1"
   while IFS= read -r line1
   do
      aws s3 ls $line1 --summarize --profile=$1 | grep PRE | awk '{print $2}' >> s3_output_list_$1

      while read line ; do
        echo "Name: $line" >> s3_main_$1

        #aws s3 ls s3://"$line"/ --summarize --human-readable --recursive --profile="$1" >> s3_main_$1.json
        aws s3 ls s3://$line1$line --recursive --summarize --human-readable --profile=$1 | grep -Ei "Total Objects: | Total Size:" >> s3_main_$1
        echo "------------------------------------------------------------------------- " >> s3_main_$1
      done < s3_output_list_$1
   done < "$input"
fi
