# IIQ EKS Cluster
## Separate EKS cluster per environment
Each environment type gets its own cluster (e.g., one for Prod, one for QA, one for Dev).
Multiple customers share the same Prod cluster (separated by namespaces).

## IIQ Databse: Amazon Aurora
Aurora is 5x faster than myqsl, storage is autoscalable, auto backup, replicate across AZ's, Recover within seconds.

### Aurora Serverless for Non-Prod
Serverless means it doesn’t run continuously. Instead, it auto-scales based on connections and workload.

### Aurora Provisioned for Prod
One Aurora provisioned cluster (Multi-AZ) for all customers.
Each customer gets its own database/schema inside that same cluster.
Prod DB is always running, with a fixed compute & storage capacity (always-on, stable, high-performance).