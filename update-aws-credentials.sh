#!/bin/bash

echo "=== Actualizador de Credenciales AWS Academy ==="
echo "1. Ve a AWS Academy Learner Lab"
echo "2. Haz clic en 'Start Lab' y espera el círculo verde"
echo "3. Haz clic en 'AWS Details'"
echo "4. Copia las credenciales y pégalas aquí:"
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
    echo ""
    echo "Ahora puedes usar comandos AWS. Ejemplo:"
    echo "aws s3 ls"
    echo "aws ec2 describe-instances"
    echo ""
    echo "⚠️  RECUERDA: Las credenciales expiran en 3-4 horas"
    echo "⚠️  Ejecuta este script nuevamente cuando expiren"
else
    echo "❌ Error de conexión. Verifica las credenciales."
fi