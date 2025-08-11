#!bin/bash

superuser_pw=pw123!
NAMESPACE=dt
release_name=dt-redpanda
# Create secret 
echo \'superuser:$superuser_pw:SCRAM-SHA-512\' >> superusers.txt

if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
  echo "Namespace '$NAMESPACE' does not exist. Creating..."
  kubectl create namespace "$NAMESPACE"
else
  echo "Namespace '$NAMESPACE' already exists."
fi

kubectl --namespace $NAMESPACE create secret generic redpanda-superusers --from-file=superusers.txt

kubectl -n $NAMESPACE create secret generic redpanda-bootstrap-user \
  --from-literal=username=superuser \
  --from-literal=password=$superuser_pw

# helm repo add $release_name https://charts.redpanda.com

helm upgrade --install dt-redpanda redpanda/redpanda \
    --version 5.10.2 \
    --namespace $NAMESPACE \
    --set statefulset.replicas=3 \
    --set tls.enabled=false \
    --set auth.sasl.enabled=true \
    --set auth.sasl.secretRef=redpanda-superusers \
    --set auth.sasl.bootstrapUser.name=superuser \
    --set auth.sasl.bootstrapUser.secretKeyRef.name=redpanda-bootstrap-user \
    --set auth.sasl.bootstrapUser.secretKeyRef.key=password \
    --set auth.sasl.bootstrapUser.mechanism=SCRAM-SHA-512 \
    --set "auth.sasl.users=null" \
    --set external.domain=vns-redpanda.local \
    --set "storage.persistentVolume.storageClass=gp3" \
    --set "image.repository=079957391273.dkr.ecr.ap-southeast-1.amazonaws.com/aidph/redpanda" \
    --set "image.tag=v25.1.2" \
    --set external.type=NodePort \
    --set console.enabled=false \
    --wait \
    --timeout 1h

helm upgrade --install dretRef=redpanda-superusers \
    --set auth.sasl.bootstrapUser.name=superuser \
    --set auth.sasl.bootstrapUser.secretKeyRef.name=redpanda-bootstrap-user \
    --set auth.sasl.bootstrapUser.secretKeyRef.key=password \
    --set auth.sasl.bootstrapUser.mechanism=SCRAM-SHA-512 \
    --set "auth.sasl.users=null" \
    --set external.domain=vns-redpanda.local \
    --set "storage.persistentVolume.storageClass=gp3" \
    --set "image.repository=079957391273.dkr.ecr.ap-southeast-1.amazonaws.com/aidph/redpanda" \
    --set "image.tag=v25.1.2" \
    --set external.type=NodePort \
    --set console.enabled=false \
    --wait 

# # Get Cluster information
kubectl --namespace $NAMESPACE exec $release_name-0 -c redpanda -- cat etc/redpanda/redpanda.yaml
# kubectl --namespace $release_name exec $release_name-0 -c redpanda -- cat etc/redpanda/redpanda.yaml

# Create user
kubectl --namespace $NAMESPACE exec -ti $release_name-0 -c redpanda -- \
rpk security user create test \
-p NyDQJrMSOVGmQCg

kubectl exec --namespace $NAMESPACE -c redpanda $release_name-0 -- \
  rpk security acl create --allow-principal User:test \
  --operation all \
  --topic all \t-redpanda redpanda/redpanda \
    --version 5.10.2 \
    --namespace dt \
    --set statefulset.replicas=3 \
    --set tls.enabled=false \
    --set auth.sasl.enabled=true \
    --set auth.sasl.sec
  -X user=superuser -X pass=$superuser_pw -X sasl.mechanism=SCRAM-SHA-512

kubectl exec --namespace $NAMESPACE -c redpanda $release_name-0 -- \
  rpk security acl create --allow-principal User:test \
  --operation all \
  -X user=superuser -X pass=$superuser_pw -X sasl.mechanism=SCRAM-SHA-512