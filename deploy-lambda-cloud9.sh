#!/bin/bash

echo "=== Desplegando Iris API a AWS Lambda desde Cloud9 ==="

# Verificar que estamos en el directorio correcto
if [ ! -f "src/main.py" ]; then
    echo "❌ Error: Ejecuta este script desde el directorio raíz del proyecto"
    exit 1
fi

# Verificar credenciales AWS
echo "1. Verificando credenciales AWS..."
aws sts get-caller-identity > /dev/null
if [ $? -ne 0 ]; then
    echo "❌ Error: Credenciales AWS no configuradas"
    echo "Asegúrate de que el Lab esté iniciado en AWS Academy"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ Conectado a cuenta AWS: $ACCOUNT_ID"

# Crear función Lambda simplificada
echo "2. Creando función Lambda..."
cat > lambda_function.py << 'EOF'
import json
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# Variables globales para el modelo
model = None
scaler = None
target_names = None

def init_model():
    """Inicializar modelo una sola vez"""
    global model, scaler, target_names
    
    if model is None:
        # Cargar dataset
        iris = load_iris()
        X_train, X_test, y_train, y_test = train_test_split(
            iris.data, iris.target, test_size=0.2, random_state=42, stratify=iris.target
        )
        
        # Entrenar scaler y modelo
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        
        model = RandomForestClassifier(n_estimators=100, random_state=42)
        model.fit(X_train_scaled, y_train)
        
        target_names = iris.target_names
        
        print("Modelo inicializado correctamente")

def lambda_handler(event, context):
    """Handler principal de Lambda"""
    try:
        # Inicializar modelo si es necesario
        init_model()
        
        # Parsear el evento
        if 'body' in event:
            if isinstance(event['body'], str):
                body = json.loads(event['body'])
            else:
                body = event['body']
        else:
            body = event
        
        # Validar entrada
        required_fields = ['sepal_length', 'sepal_width', 'petal_length', 'petal_width']
        for field in required_fields:
            if field not in body:
                raise ValueError(f"Campo requerido faltante: {field}")
        
        # Extraer características
        features = np.array([
            float(body['sepal_length']),
            float(body['sepal_width']),
            float(body['petal_length']),
            float(body['petal_width'])
        ]).reshape(1, -1)
        
        # Escalar características
        features_scaled = scaler.transform(features)
        
        # Realizar predicción
        prediction = model.predict(features_scaled)[0]
        probabilities = model.predict_proba(features_scaled)[0]
        
        # Preparar respuesta
        response = {
            'prediction': int(prediction),
            'class_name': target_names[prediction],
            'probabilities': {
                target_names[i]: float(prob) 
                for i, prob in enumerate(probabilities)
            },
            'input_features': {
                'sepal_length': float(body['sepal_length']),
                'sepal_width': float(body['sepal_width']),
                'petal_length': float(body['petal_length']),
                'petal_width': float(body['petal_width'])
            }
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps(response)
        }
        
    except ValueError as e:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Datos de entrada inválidos',
                'message': str(e)
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Error interno del servidor',
                'message': str(e)
            })
        }
EOF

# Crear paquete de despliegue
echo "3. Creando paquete de despliegue..."
rm -rf lambda-package iris-lambda.zip
mkdir lambda-package

# Copiar función
cp lambda_function.py lambda-package/

# Instalar dependencias en el paquete
echo "4. Instalando dependencias..."
pip install scikit-learn numpy -t lambda-package/ --quiet

# Crear ZIP
echo "5. Creando archivo ZIP..."
cd lambda-package
zip -r ../iris-lambda.zip . > /dev/null
cd ..

echo "6. Desplegando función Lambda..."

# Eliminar función existente si existe
aws lambda delete-function --function-name iris-classifier 2>/dev/null

# Crear nueva función
aws lambda create-function \
    --function-name iris-classifier \
    --runtime python3.9 \
    --role arn:aws:iam::$ACCOUNT_ID:role/LabRole \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://iris-lambda.zip \
    --timeout 30 \
    --memory-size 512 \
    --description "API de clasificación de Iris con ML"

if [ $? -eq 0 ]; then
    echo "✅ Función Lambda creada exitosamente"
    
    # Probar la función
    echo "7. Probando función Lambda..."
    aws lambda invoke \
        --function-name iris-classifier \
        --payload '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}' \
        response.json
    
    echo "Respuesta de la función:"
    cat response.json | python3 -m json.tool
    
    echo ""
    echo "=== Despliegue Completado ==="
    echo "Función Lambda: iris-classifier"
    echo "Región: us-east-1"
    echo "ARN: arn:aws:lambda:us-east-1:$ACCOUNT_ID:function:iris-classifier"
    echo ""
    echo "Próximos pasos:"
    echo "1. Configurar API Gateway para exponer la función"
    echo "2. O usar la función directamente desde otros servicios AWS"
    echo ""
    echo "Para probar manualmente:"
    echo "aws lambda invoke --function-name iris-classifier --payload '{\"sepal_length\": 6.0, \"sepal_width\": 3.0, \"petal_length\": 4.0, \"petal_width\": 1.5}' output.json"
    
else
    echo "❌ Error al crear función Lambda"
    echo "Verifica los permisos y que el Lab esté activo"
fi

# Limpiar archivos temporales
rm -f lambda_function.py response.json
rm -rf lambda-package iris-lambda.zip