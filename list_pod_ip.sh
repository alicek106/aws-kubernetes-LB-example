#!/bin/bash
echo --- master --
kubectl get po -n ingress-nginx -o yaml | grep podIP
echo --- pod ---
kubectl get po -o yaml | grep podIP
