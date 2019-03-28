


export SUBNET_ID=$(aws ec2 describe-subnets --region ap-northeast-2  \
--filters Name=tag:Name,Values=kubernetes | jq ".Subnets[0].SubnetId" -r)
echo $SUBNET_ID

export VPC_ID=$(aws ec2 describe-vpcs --region ap-northeast-2 \
--filters Name=tag:Name,Values=kubernetes | jq ".Vpcs[0].VpcId" -r)
echo $VPC_ID

# NLB 생성
export NLB_ARN=$(aws elbv2 create-load-balancer --region ap-northeast-2 \
  --name ingress-test-lb --type network \
  --subnets $SUBNET_ID | jq ".LoadBalancers[0].LoadBalancerArn" -r)
echo $NLB_ARN

# 타겟 그룹 생성
export TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
  --name ingress-target-group --region ap-northeast-2 \
  --protocol TCP --port 30000 \
  --vpc-id $VPC_ID | jq ".TargetGroups[0].TargetGroupArn" -r)
echo $TARGET_GROUP_ARN

# 인스턴스 등록
aws elbv2 register-targets --region ap-northeast-2 \
  --target-group-arn $TARGET_GROUP_ARN \
  --targets $(bash get_instance_id_list.sh)

# 리스너 생성
aws elbv2 create-listener --region ap-northeast-2 \
  --load-balancer-arn $NLB_ARN \
  --protocol TCP --port 80  \
  --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

# HealthCheck

aws elbv2 describe-target-health --region ap-northeast-2 \
  --target-group-arn $TARGET_GROUP_ARN

# https://docs.aws.amazon.com/ko_kr/elasticloadbalancing/latest/network/network-load-balancer-cli.html

# URL  확인

aws elbv2 describe-load-balancers \
--region ap-northeast-2 | jq ".LoadBalancers[0].DNSName" -r

ingress-test-lb-4359a85a11571425.elb.ap-northeast-2.amazonaws.com


# Clean Up

aws elbv2 delete-load-balancer --region ap-northeast-2 --load-balancer-arn $NLB_ARN
aws elbv2 delete-target-group --region ap-northeast-2 --target-group-arn $TARGET_GROUP_ARN

