# Testing the IIQ Image Using Docker Compose 🐳

Docker Compose is used to verify IIQ's functionality and connectivity with MySQL and `identityiq.war`.

To run the project, simply execute:

```bash
docker compose up
```

This will apply the `compose.yml` configuration and create two containers:

- `iiq-container-poc_iiq_1`
- `iiq-container-poc_db_1`

Once started successfully, access the application at:  
**https://docker-host-ip:9000/identityiq/**

IIQ requires MySQL as its database server, so both containers need to be running and connected.

- The IIQ image is built using `../image-iiq/Dockerfile`.
- Environment variables are configured through the `.env` file. It provide DB username and password to IIQ.
- IIQ application setup is handled by `../image-iiq/script/install_iiq.sh` and customized using Tomcat config from `../image-iiqq/config/*`.
- The `identityiq.war` file in `../image-iiq/build/deploy` is a placeholder and should be replaced with a current or customer-specific artifact.