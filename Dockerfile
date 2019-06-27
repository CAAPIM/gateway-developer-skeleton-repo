FROM caapim/gateway:latest
## Copying the deployment package
COPY deployment/build/gateway/deployment-0.6.0.gw7 /opt/docker/rc.d/deployment.gw7
## Make restman available
RUN touch /opt/SecureSpan/Gateway/node/default/etc/bootstrap/services/restman