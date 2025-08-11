#!/bin/bash


helm repo add redpanda https://charts.redpanda.com
helm repo update

helm upgrade --install redpanda-connect-<name-convention> redpanda/redpanda-connect \
    --namespace redpanda-connect --create-namespace \
    -f <values-file>


helm upgrade --install redpanda-connect-notify-telegram redpanda2/redpanda-connect \
    --namespace redpanda2 --create-namespace \
    -f redpanda-v2/redpanda-connect/redpanda-nats-notify-telegram.yaml

    .idea/redpanda-v2/redpanda-connect/redpanda-nats-notify-telegram.yaml

helm search repo redpanda2


helm upgrade --install redpanda-connect-sink redpanda2/connect \
    --namespace redpanda2 --create-namespace \
    -f redpanda-v2/redpanda-connect/redpanda-s3-template.yaml

helm upgrade --install kafka-connect redpanda2/connect \
    --namespace redpanda2 --create-namespace \
    -f redpanda-v2/redpanda-connect/values.yaml

helm upgrade --install kafka-connect . -n test-deploy -f values.yaml