# IIQ EKS Cluster


## IIQ Databse: Amazon Aurora
Each customer and each environment: gets a separate Aurora cluster → good isolation between customers.
### Aurora Serverless for Non-Prod
Serverless means it doesn’t run continuously. Instead, it auto-scales based on connections and workload.

### Aurora Provisioned for Prod
Prod DB is always running, with a fixed compute & storage capacity (always-on, stable, high-performance).