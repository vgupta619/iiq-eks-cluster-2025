# Environments

## _init
This is initial environment setup to create s3 backend and statelock dynamodb.
You should first deploy this environment and then any other.
Create:
1. s3 bucket to store statefile.
2. dynamodb table to store state lock.

## dev
This is test environment to deploy IIQ in eks cluster.
Create:
1. Dev VPC.
2. dev EKS cluster.
3. serverless aurora for non-prod.
4. deploy karpenter autoscaler.
5. deploy metric server in the cluster and help karpenter for scaling.
6. enable cloudwatch monitoring. 

## prod
This is production environment to deploy IIQ in eks cluster.
Create:
1. Prod VPC.
2. Prod EKS cluster.
3. provisioned aurora for prod.
4. deploy karpenter autoscaler.
5. deploy metric server in the cluster and help karpenter for scaling.
6. enable cloudwatch monitoring. 

## util
This is utility environment which deploy all platform util tools. This should be deploy at last.
Create:
1. Util VPC
2. Util EKS cluster
3. Deploy Argocd
    Then ArgoCD deploy
    a. Jenkins
    b. prometheous
    c. grafan
    d. cert-manager
    e. loki 
    
