# BrokerOne Kafka local no Minikube

Este pacote sobe **o worker Kafka Laravel** localmente no Minikube, com foco em teste de boot, consumo e autoscaling com KEDA.

## O que tem aqui

- `namespace.yaml` — namespace `kafka-local`
- `deployment-local.yaml` — worker Kafka usando a imagem `brokerone-kafka:local`
- `scaledobject-local-noauth.yaml` — KEDA para Kafka sem autenticação
- `scaledobject-local-sasl.yaml` — KEDA para Kafka com SASL/TLS via TriggerAuthentication
- `triggerauth-local.yaml` — autenticação KEDA para Kafka SASL/TLS
- `keda-kafka-secret.sample.yaml` — secret de exemplo para o KEDA
- `.env.minikube.sample` — env mínima para o worker
- `create-secret.sh` — cria o secret Kubernetes a partir do `.env.minikube`
- `create-secret.ps1` — mesma coisa para PowerShell

## Pré-requisitos

- Minikube instalado e iniciado
- `kubectl` funcionando
- imagem local do worker construída
- KEDA instalado no cluster se você quiser testar autoscaling

## 1) Iniciar Minikube

```bash
minikube start
```

## 2) Build da imagem

No diretório do projeto, ajuste o caminho do build conforme o seu contexto Docker:

```bash
docker build -f Dockerfile-kafka-dev -t brokerone-kafka:local .
minikube image load brokerone-kafka:local
```

## 3) Criar a env local

Copie o arquivo de exemplo:

```bash
cp .env.minikube.sample .env.minikube
```

Edite o `.env.minikube` e ajuste os hosts conforme seu ambiente:

- use `host.minikube.internal` se MySQL/Redis/Mongo/Kafka estiverem na sua máquina host
- use o nome do Service Kubernetes se eles estiverem dentro do cluster

## 4) Aplicar namespace

```bash
kubectl apply -f namespace.yaml
```

## 5) Criar o secret com as envs

Linux/macOS:

```bash
chmod +x create-secret.sh
./create-secret.sh
```

PowerShell:

```powershell
./create-secret.ps1
```

## 6) Subir o worker

```bash
kubectl apply -f deployment-local.yaml
kubectl get pods -n kafka-local
kubectl logs -f deployment/brokerone-kafka-local -n kafka-local
```

## 7) Testar KEDA

### Kafka sem auth

```bash
kubectl apply -f scaledobject-local-noauth.yaml
```

### Kafka com SASL/TLS

1. Ajuste `keda-kafka-secret.sample.yaml`
2. aplique o secret e o trigger auth
3. aplique o scaledobject com auth

```bash
kubectl apply -f keda-kafka-secret.sample.yaml
kubectl apply -f triggerauth-local.yaml
kubectl apply -f scaledobject-local-sasl.yaml
```

## Comandos úteis

```bash
kubectl get all -n kafka-local
kubectl describe deployment brokerone-kafka-local -n kafka-local
kubectl logs -f deployment/brokerone-kafka-local -n kafka-local
kubectl get scaledobject -n kafka-local
kubectl describe scaledobject brokerone-kafka-local-scaledobject -n kafka-local
kubectl get hpa -n kafka-local
kubectl top pods -n kafka-local
```

## Observações importantes

- esta imagem é um **worker Kafka**, não uma app web; por isso não há `Service` nem `containerPort`
- o Deployment usa `preStop` com `sleep 10` e `terminationGracePeriodSeconds: 150`
- o worker sobe com `envFrom` a partir de um secret Kubernetes criado do arquivo `.env.minikube`
- se o comando `php artisan kafka:start` depender de mais variáveis no boot, os logs vão indicar o que faltou

## Primeiro teste recomendado

Suba **só o Deployment** primeiro. Quando a pod ficar estável, teste o KEDA.
