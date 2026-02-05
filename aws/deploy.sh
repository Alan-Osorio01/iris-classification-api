#!/bin/bash

# Configuración
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="YOUR_ACCOUNT_ID"
ECR_REPOSITORY="iris-classifier"
CLUSTER_NAME="iris-cluster"
SERVICE_NAME="iris-service"

echo "=== Desplegando Iris Classifier en AWS ==="

# 1. Crear repositorio ECR si no existe
echo "1. Creando repositorio ECR..."
aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION 2>/dev/null || \
aws ecr create-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION

# 2. Obtener token de login para ECR
echo "2. Obteniendo token de ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 3. Construir imagen Docker
echo "3. Construyendo imagen Docker..."
docker build -t $ECR_REPOSITORY .

# 4. Etiquetar imagen
echo "4. Etiquetando imagen..."
docker tag $ECR_REPOSITORY:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest

# 5. Subir imagen a ECR
echo "5. Subiendo imagen a ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest

# 6. Actualizar task definition con el ACCOUNT_ID correcto
echo "6. Actualizando task definition..."
sed "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g; s/REGION/$AWS_REGION/g" aws/task-definition.json > aws/task-definition-updated.json

# 7. Registrar nueva task definition
echo "7. Registrando task definition..."
aws ecs register-task-definition --cli-input-json file://aws/task-definition-updated.json --region $AWS_REGION

# 8. Crear cluster si no existe
echo "8. Creando cluster ECS..."
aws ecs describe-clusters --clusters $CLUSTER_NAME --region $AWS_REGION 2>/dev/null || \
aws ecs create-cluster --cluster-name $CLUSTER_NAME --capacity-providers FARGATE --region $AWS_REGION

# 9. Crear o actualizar servicio
echo "9. Creando/actualizando servicio..."
aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION 2>/dev/null && \
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition iris-classifier --region $AWS_REGION || \
aws ecs create-service \
  --cluster $CLUSTER_NAME \
  --service-name $SERVICE_NAME \
  --task-definition iris-classifier \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678],assignPublicIp=ENABLED}" \
  --region $AWS_REGION

echo "=== Despliegue completado ==="
echo "Verifica el estado del servicio con:"
echo "aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION"