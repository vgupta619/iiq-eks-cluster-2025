# Project to containerize IIQ and deploy in EKS cluster.
This project aims to containerize the IIQ application.

This repository is organized into modular platform components, each representing a distinct domain in the IIQ delivery ecosystem:
• `eks-cluster-iiq`: Infrastructure provisioning via Terraform
• `gitops-iiq`: GitOps bootstrapping and cluster-specific manifests
• `image-iiq`: Container image build and deployment scripts
• `pipeline-iiq`: CI/CD pipeline definitions 
• `docker-compose-test-iiq`: Local development and testing setup for iiq

## IIQ Image Details 🛠️

- The IIQ image is always built from the `image-iiq/Dockerfile` directory.
- It must include the latest or customized `identityiq.war` file in `image-iiq/build/deploy`.
- Once built, push the image to a container repository for Kubernetes deployment.

## Testing the IIQ Image Using Docker Compose 🐳

Docker Compose is used to verify IdentityIQ's functionality and connectivity with MySQL and `identityiq.war`.

To run the project, simply execute:

```bash
cd docker-compose-test-iiq
docker compose up
```

This will apply the `compose.yml` configuration and create two containers:

- `iiq-container-poc_iiq_1`
- `iiq-container-poc_db_1`

Once started successfully, access the application at:  
**https://docker-host-ip:9000/identityiq/**

IdentityIQ requires MySQL as its database server, so both containers need to be running and connected.

- The IIQ image is built using `image-iiq/Dockerfile`.
- Environment variables are configured through the `.env` file.
- IIQ application setup is handled by `image-iiq/script/install_iiq.sh` and customized using Tomcat config from `image-iiq/config/*`.
- The `identityiq.war` file in `image-iiq/build/deploy` is a placeholder and should be replaced with a current or customer-specific artifact.

## IIQ Build Pipeline ⚙️

The build pipeline should:

1. Build the IdentityIQ application from `image-iiq/build/identityiq.zip` and output to `image-iiq/build/deploy/identityiq.war`.
2. Build the IIQ Docker image.
3. Push the image to a container repository.

## ArgoCD Deployment 🚀

ArgoCD is used to deploy IdentityIQ to a Kubernetes cluster.  
Find the ArgoCD configuration here:  
[GitOps Kubernetes ArgoCD Configuration](https://github.com/vgupta619/iiq-eks-cluster-2025.git/gitops-iiq/)

ArgoCD will automatically detect and deploy the latest image from the repository.

## IIQ EKS Clustert 
Cluster can be create using terraform from - `/eks-cluster-iiq`
1. Saperate EKS cluster for dev and prod.
2. Aurora as DB cluster, 
    1. provisioned aurora for Prod.
    2. Serverless aurora for Dev.

More details can be found in README.md files of each functional unit of this project.