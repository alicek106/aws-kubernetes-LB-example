#!/bin/bash
export NLB_PUBLIC_DNS=$(kubectl get svc -n ingress-nginx ingress-nginx \
  -o json | jq ".status.loadBalancer.ingress[0].hostname" -r)

cat 3-ingress.yaml | sed "s/{{NLB_PUBLIC_DNS}}/$NLB_PUBLIC_DNS/g" | kubectl delete -f -
