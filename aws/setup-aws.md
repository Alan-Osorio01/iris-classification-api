# Configuración de AWS para el Proyecto Iris

## 1. Configurar Credenciales AWS

### Opción A: AWS CLI (Recomendado)
```bash
# Instalar AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configurar credenciales
aws configure
```

Te pedirá:
- **AWS Access Key ID**: Proporcionado por tu universidad
- **AWS Secret Access Key**: Proporcionado por tu universidad  
- **Default region**: `us-east-1` (o la región que te asignaron)
- **Default output format**: `json`

### Opción B: Variables de Entorno
```bash
export AWS_ACCESS_KEY_ID="tu-access-key"
export AWS_SECRET_ACCESS_KEY="tu-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Opción C: Archivo de Credenciales
Crear archivo `~/.aws/credentials`:
```ini
[default]
aws_access_key_id = tu-access-key
aws_secret_access_key = tu-secret-key
region = us-east-1
```

## 2. Verificar Conexión
```bash
# Verificar que las credenciales funcionan
aws sts get-caller-identity

# Debería mostrar algo como:
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/tu-usuario"
# }
```

## 3. Permisos Necesarios

Tu cuenta de AWS debe tener los siguientes permisos:

### ECR (Elastic Container Registry)
- `ecr:CreateRepository`
- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:GetDownloadUrlForLayer`
- `ecr:BatchGetImage`
- `ecr:PutImage`

### ECS (Elastic Container Service)
- `ecs:CreateCluster`
- `ecs:CreateService`
- `ecs:UpdateService`
- `ecs:RegisterTaskDefinition`
- `ecs:DescribeClusters`
- `ecs:DescribeServices`
- `ecs:DescribeTaskDefinition`

### IAM (para roles de ECS)
- `iam:PassRole`

### CloudWatch Logs
- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`

## 4. Configurar Infraestructura Básica

### Crear VPC y Subnets (si no existen)
```bash
# Obtener VPC por defecto
aws ec2 describe-vpcs --filters "Name=is-default,Values=true"

# Obtener subnets públicas
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxxxxx" "Name=map-public-ip-on-launch,Values=true"

# Obtener security group por defecto
aws ec2 describe-security-groups --filters "Name=group-name,Values=default"
```

### Crear Roles IAM Necesarios
```bash
# Crear rol de ejecución de tareas ECS
aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'

# Adjuntar política
aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Crear rol de tarea ECS
aws iam create-role --role-name ecsTaskRole --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'
```

## 5. Actualizar Configuración del Proyecto

1. **Editar `aws/deploy.sh`**:
   - Cambiar `YOUR_ACCOUNT_ID` por tu Account ID real
   - Verificar la región (`us-east-1`)
   - Actualizar subnet y security group IDs

2. **Editar `aws/task-definition.json`**:
   - Los placeholders se actualizan automáticamente en el script

## 6. Comandos Útiles

### Verificar recursos
```bash
# Ver repositorios ECR
aws ecr describe-repositories

# Ver clusters ECS
aws ecs list-clusters

# Ver servicios en un cluster
aws ecs list-services --cluster iris-cluster

# Ver logs de CloudWatch
aws logs describe-log-groups --log-group-name-prefix "/ecs/iris"
```

### Limpiar recursos
```bash
# Eliminar servicio
aws ecs update-service --cluster iris-cluster --service iris-service --desired-count 0
aws ecs delete-service --cluster iris-cluster --service iris-service

# Eliminar cluster
aws ecs delete-cluster --cluster iris-cluster

# Eliminar repositorio ECR
aws ecr delete-repository --repository-name iris-classifier --force
```

## 7. Solución de Problemas Comunes

### Error de permisos
- Verificar que las credenciales sean correctas
- Contactar al administrador de AWS de tu universidad

### Error de VPC/Subnet
- Usar las subnets y security groups proporcionados por tu universidad
- Verificar que las subnets tengan acceso a internet

### Error de límites
- AWS Educate tiene límites en recursos
- Verificar cuotas disponibles en la consola AWS