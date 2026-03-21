#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="kafka-local"
SECRET_NAME="brokerone-kafka-local-env"
ENV_FILE=".env.minikube"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Arquivo $ENV_FILE não encontrado no diretório atual."
  exit 1
fi

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE" --ignore-not-found
kubectl create secret generic "$SECRET_NAME" \
  --from-env-file="$ENV_FILE" \
  -n "$NAMESPACE"

echo "Secret $SECRET_NAME criado no namespace $NAMESPACE."
