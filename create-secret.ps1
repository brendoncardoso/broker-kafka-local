$Namespace = "kafka-local"
$SecretName = "brokerone-kafka-local-env"
$EnvFile = ".env.minikube"

if (-not (Test-Path $EnvFile)) {
    Write-Error "Arquivo $EnvFile não encontrado no diretório atual."
    exit 1
}

kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -
kubectl delete secret $SecretName -n $Namespace --ignore-not-found
kubectl create secret generic $SecretName --from-env-file=$EnvFile -n $Namespace

Write-Host "Secret $SecretName criado no namespace $Namespace."
