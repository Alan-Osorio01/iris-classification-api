# Configuración AWS Academy (Credenciales Temporales)

## Paso 1: Acceder a AWS Academy

1. Entra a tu curso de AWS Academy
2. Haz clic en "AWS Academy Learner Lab" o "AWS Console"
3. Haz clic en "Start Lab" (si no está iniciado)
4. Espera a que el círculo se ponga verde
5. Haz clic en "AWS Details"

## Paso 2: Obtener Credenciales Temporales

En "AWS Details" verás algo como:
```
AWS CLI:
aws_access_key_id = ASIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
aws_session_token = IQoJb3JpZ2luX2VjEPT//////////wEaCXVzLXdlc3QtMSJHMEUCIQD...
```

## Paso 3: Configurar Credenciales (SIN aws configure)

### Opción A: Variables de Entorno (Recomendado)
```bash
# Copiar y pegar las credenciales de AWS Academy
export AWS_ACCESS_KEY_ID="ASIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEPT//////////wEaCXVzLXdlc3QtMSJHMEUCIQD..."
export AWS_DEFAULT_REGION="us-east-1"
```

### Opción B: Archivo de Credenciales Temporal
```bash
# Crear directorio si no existe
mkdir -p ~/.aws

# Crear archivo de credenciales
cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = ASIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
aws_session_token = IQoJb3JpZ2luX2VjEPT//////////wEaCXVzLXdlc3QtMSJHMEUCIQD...
region = us-east-1
EOF
```

## Paso 4: Verificar Conexión

```bash
# Verificar que funciona
aws sts get-caller-identity

# Debería mostrar tu Account ID y usuario
```

## Paso 5: Ver Qué Servicios Tienes Disponibles

```bash
# Ver regiones disponibles
aws ec2 describe-regions

# Ver si puedes crear repositorios ECR
aws ecr describe-repositories

# Ver clusters ECS disponibles
aws ecs list-clusters
```

## Limitaciones Comunes en Cuentas Educativas

- Pueden tener regiones restringidas
- Límites en tipos de instancias
- Algunos servicios pueden estar deshabilitados
- Presupuesto limitado

## Si Tienes Problemas

1. **Error de permisos**: Contacta al administrador AWS de tu universidad
2. **Región incorrecta**: Pregunta qué región debes usar
3. **Servicios no disponibles**: Verifica qué servicios están habilitados en tu cuenta educativa

## Paso 4: Verificar Conexión

```bash
# Verificar que funciona
aws sts get-caller-identity

# Debería mostrar algo como:
# {
#     "UserId": "AROABC123DEFGHIJKLMN:user12345",
#     "Account": "123456789012",
#     "Arn": "arn:aws:sts::123456789012:assumed-role/LabRole/user12345"
# }
```

## Paso 5: Script para Actualizar Credenciales

Crea un script para facilitar la actualización de credenciales:

```bash
# Crear script update-aws-credentials.sh
cat > update-aws-credentials.sh << 'EOF'
#!/bin/bash

echo "=== Actualizador de Credenciales AWS Academy ==="
echo "Copia las credenciales de AWS Academy y pégalas aquí:"
echo ""

read -p "AWS Access Key ID: " ACCESS_KEY
read -p "AWS Secret Access Key: " SECRET_KEY
read -p "AWS Session Token: " SESSION_TOKEN

export AWS_ACCESS_KEY_ID="$ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$SECRET_KEY"
export AWS_SESSION_TOKEN="$SESSION_TOKEN"
export AWS_DEFAULT_REGION="us-east-1"

echo ""
echo "Credenciales configuradas. Verificando conexión..."
aws sts get-caller-identity

if [ $? -eq 0 ]; then
    echo "✅ Conexión exitosa a AWS"
    
    # Guardar en archivo para esta sesión
    mkdir -p ~/.aws
    cat > ~/.aws/credentials << EOL
[default]
aws_access_key_id = $ACCESS_KEY
aws_secret_access_key = $SECRET_KEY
aws_session_token = $SESSION_TOKEN
region = us-east-1
EOL
    
    echo "Credenciales guardadas en ~/.aws/credentials"
else
    echo "❌ Error de conexión. Verifica las credenciales."
fi
EOF

chmod +x update-aws-credentials.sh
```

## Limitaciones de AWS Academy

- **Credenciales temporales**: Expiran cada 3-4 horas
- **Sesión limitada**: El lab se apaga automáticamente
- **Servicios restringidos**: Solo algunos servicios están disponibles
- **Regiones limitadas**: Generalmente solo `us-east-1`
- **Presupuesto**: $100 USD típicamente

## Servicios Disponibles en AWS Academy

Generalmente tienes acceso a:
- ✅ EC2 (instancias básicas)
- ✅ S3 (almacenamiento)
- ✅ Lambda (funciones)
- ✅ API Gateway
- ✅ CloudFormation
- ❌ ECS/Fargate (puede estar limitado)
- ❌ ECR (puede estar limitado)

## Alternativas de Despliegue para AWS Academy

### Opción 1: AWS Lambda + API Gateway
```bash
# Más compatible con AWS Academy
# Usar Serverless Framework o SAM
```

### Opción 2: EC2 Simple
```bash
# Desplegar en una instancia EC2 básica
# Usar Docker en la instancia
```

### Opción 3: S3 + CloudFront (Solo frontend)
```bash
# Para aplicaciones estáticas
```

## Workflow Recomendado para AWS Academy

1. **Iniciar Lab** en AWS Academy
2. **Copiar credenciales** de "AWS Details"
3. **Ejecutar script** `./update-aws-credentials.sh`
4. **Trabajar rápido** (antes de que expire)
5. **Repetir** cuando las credenciales expiren

## Comandos Útiles

```bash
# Verificar tiempo restante del lab
aws sts get-caller-identity

# Ver servicios disponibles
aws iam list-attached-role-policies --role-name LabRole

# Ver límites de la cuenta
aws service-quotas list-service-quotas --service-code ec2
```