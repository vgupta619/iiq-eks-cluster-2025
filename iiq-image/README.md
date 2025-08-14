# IIQ Image Details 🛠️

IIQ requires MySQL as its database server, so both containers(IIQ+MySQL) need to be running and connected.

- The IIQ image is built using `Dockerfile`.
- Environment variables are configured through the `.env` file.
- IIQ application setup is handled by `/script/install_iiq.sh` and customized using Tomcat config from `/config/*`.
- The `identityiq.war` file in `/build/deploy` is a placeholder and should be replaced with a current or customer-specific artifact.
- Once built, push the image to a container repository for Kubernetes deployment.

## ArgoCD Deployment 🚀

ArgoCD is used to deploy IdentityIQ to a Kubernetes cluster.  
Find the ArgoCD configuration here:  
[GitOps Kubernetes ArgoCD Configuration](https://github.com/vgupta619/gitops-k8s-2023/tree/main/eks/argocd)

ArgoCD will automatically detect and deploy the latest image from the repository.