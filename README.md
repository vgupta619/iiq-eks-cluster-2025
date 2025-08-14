# Project to containerize IIQ and deploy in EKS cluster.
This project aims to containerize the IIQ application.

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
**https://<docker-host-ip>:9000/identityiq/**

IdentityIQ requires MySQL as its database server, so both containers need to be running and connected.

- The IIQ image is built using `iiq-image/Dockerfile`.
- Environment variables are configured through the `.env` file.
- IIQ application setup is handled by `iiq-image/script/install_iiq.sh` and customized using Tomcat config from `iiq-image/config/*`.
- The `identityiq.war` file in `iiq-image/build/deploy` is a placeholder and should be replaced with a current or customer-specific artifact.

## IIQ Image Details 🛠️

- The IIQ image is always built from the `iiq-image/Dockerfile` directory.
- It must include the latest or customized `identityiq.war` file in `iiq-image/build/deploy`.
- Once built, push the image to a container repository for Kubernetes deployment.

## IIQ Build Pipeline ⚙️

The build pipeline should:

1. Build the IdentityIQ application from `iiq-image/build/identityiq.zip` and output to `iiq-image/build/deploy/identityiq.war`.
2. Build the IIQ Docker image.
3. Push the image to a container repository.

## ArgoCD Deployment 🚀

ArgoCD is used to deploy IdentityIQ to a Kubernetes cluster.  
Find the ArgoCD configuration here:  
[GitOps Kubernetes ArgoCD Configuration](https://github.com/vgupta619/gitops-k8s-2023/tree/main/eks/argocd)

ArgoCD will automatically detect and deploy the latest image from the repository.

## IIQ EKS Clustert 
Cluster can be create using terraform from - `/eks-cluster`