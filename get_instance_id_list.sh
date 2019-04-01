#!/bin/bash
source /root/awscli-env/bin/activate

raw_json_data=$(aws ec2 describe-instances --region ap-northeast-2 \
  --filters "Name=tag:ansibleNodeType,Values=worker" | jq ".Reservations" -r)
number_of_kubernetes_instance=$(echo $raw_json_data | jq length)

for (( c=0; c<=$number_of_kubernetes_instance-1; c++ ))
do 
   printf "Id=$(echo $raw_json_data | jq ".[$c].Instances[0].InstanceId" -r) "
done

