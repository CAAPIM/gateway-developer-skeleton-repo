FROM docker.stable1.apimgcp.com/repository/docker-hosted/gateway:wlui-test
## Copying the deployment package
COPY build/gateway/demo-1.0.0.gw7 /opt/docker/rc.d/deployment.gw7
COPY src/main/gateway/config/env.properties /opt/SecureSpan/Gateway/node/default/etc/bootstrap/env/env.properties
## Make restman available
RUN touch /opt/SecureSpan/Gateway/node/default/etc/bootstrap/services/restman
