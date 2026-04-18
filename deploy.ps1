<#
Build and deploy Kafka Connect + Oracle connector for OpenShift with Strimzi.
Run from the repository root in PowerShell.
#>

param(
    [string]$ImageTag = "v2",
    [string]$Namespace = "lakehouse-ingest"
)

$imageName = "docker.io/shaikhabdullah1610/openshit_poc:$ImageTag"

Write-Host "Building Docker image: $imageName"
docker build -t $imageName .

Write-Host "Pushing Docker image"
docker push $imageName

Write-Host "Applying combined OpenShift manifest"
oc apply -f .\openshift-kafka-connect-oracle.yaml

Write-Host "Waiting for KafkaConnect pod to become Ready"
oc wait --for=condition=Ready pod -l strimzi.io/name=lakehouse-connector -n $Namespace --timeout=300s

Write-Host "Connector status"
oc get kafkaconnector -n $Namespace
