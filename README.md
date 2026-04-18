# OpenShift Kafka Connect + Oracle Deployment

This repository contains a custom Strimzi Kafka Connect image and deployment artifacts for OpenShift:

- `Dockerfile` - builds a custom Kafka Connect image with Debezium Oracle and JDBC connectors
- `lakehouse-connector.yaml` - KafkaConnect CR for Strimzi
- `oracle-source-connector.yaml` - KafkaConnector CR for Debezium Oracle source connector
- `openshift-kafka-connect-oracle.yaml` - combined OpenShift deployment manifest for both resources
- `deploy.ps1` - PowerShell helper to build, push, and deploy the manifests

## Ready-to-use deployment steps

1. Build and push the image:
   ```powershell
   .\deploy.ps1 -ImageTag v2
   ```

2. Apply the combined OpenShift deployment manifest:
   ```powershell
   oc apply -f .\openshift-kafka-connect-oracle.yaml
   ```

3. Wait for the Kafka Connect pod to become `1/1 Ready`:
   ```powershell
   oc wait --for=condition=Ready pod -l strimzi.io/name=lakehouse-connector -n lakehouse-ingest --timeout=300s
   ```

4. Check the connector status:
   ```powershell
   oc get kafkaconnector -n lakehouse-ingest
   ```

## Notes

- `lakehouse-connector.yaml` uses `imagePullPolicy: Always` to avoid stale cached images.
- The image tag should be explicit and not use `latest`.
- `Dockerfile` now sets `KAFKA_LOG4J_OPTS` to point at `/opt/kafka/custom-config/log4j.properties`.
- The Dockerfile applies `chown -R 1001:0 /opt/kafka` and `chmod -R g+rwX /opt/kafka` to satisfy OpenShift/SCC non-root requirements.
- `oracle-source-connector.yaml` uses the full cluster DNS for the Kafka bootstrap server and the Debezium Oracle history topic config.
- If Oracle credentials must be rotated, replace `database.user` and `database.password` in `oracle-source-connector.yaml` before deployment.
