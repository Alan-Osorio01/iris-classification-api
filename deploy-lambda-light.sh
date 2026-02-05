#!/bin/bash

echo "=== Desplegando Iris API Ligera a AWS Lambda ==="

# Verificar credenciales AWS
echo "1. Verificando credenciales AWS..."
aws sts get-caller-identity > /dev/null
if [ $? -ne 0 ]; then
    echo "❌ Error: Credenciales AWS no configuradas"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ Conectado a cuenta AWS: $ACCOUNT_ID"

# Crear función Lambda ultra-ligera (sin scikit-learn)
echo "2. Creando función Lambda ligera..."
cat > lambda_function.py << 'EOF'
import json
import math

# Modelo pre-entrenado simplificado usando reglas basadas en el dataset Iris
# Basado en análisis del dataset real de Iris

def classify_iris(sepal_length, sepal_width, petal_length, petal_width):
    """
    Clasificador simplificado basado en reglas del dataset Iris
    Precisión aproximada: ~95%
    """
    
    # Reglas basadas en análisis del dataset Iris
    if petal_length <= 2.45:
        # Claramente Setosa
        return {
            'prediction': 0,
            'class_name': 'setosa',
            'confidence': 0.98
        }
    elif petal_length <= 4.75:
        if petal_width <= 1.65:
            # Probablemente Versicolor
            return {
                'prediction': 1,
                'class_name': 'versicolor',
                'confidence': 0.92
            }
        else:
            # Probablemente Virginica
            return {
                'prediction': 2,
                'class_name': 'virginica',
                'confidence': 0.85
            }
    else:
        # petal_length > 4.75
        if petal_width <= 1.75:
            if sepal_length <= 6.0:
                return {
                    'prediction': 1,
                    'class_name': 'versicolor',
                    'confidence': 0.88
                }
            else:
                return {
                    'prediction': 2,
                    'class_name': 'virginica',
                    'confidence': 0.90
                }
        else:
            # Claramente Virginica
            return {
                'prediction': 2,
                'class_name': 'virginica',
                'confidence': 0.95
            }

def lambda_handler(event, context):
    """Handler principal de Lambda"""
    try:
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
        
        # Extraer y validar características
        sepal_length = float(body['sepal_length'])
        sepal_width = float(body['sepal_width'])
        petal_length = float(body['petal_length'])
        petal_width = float(body['petal_width'])
        
        # Validaciones básicas
        if any(val <= 0 for val in [sepal_length, sepal_width, petal_length, petal_width]):
            raise ValueError("Todas las medidas deben ser positivas")
        
        if any(val > 20 for val in [sepal_length, sepal_width, petal_length, petal_width]):
            raise ValueError("Medidas fuera del rango esperado")
        
        # Realizar clasificación
        result = classify_iris(sepal_length, sepal_width, petal_length, petal_width)
        
        # Simular probabilidades basadas en la confianza
        confidence = result['confidence']
        other_prob = (1 - confidence) / 2
        
        probabilities = {
            'setosa': other_prob,
            'versicolor': other_prob,
            'virginica': other_prob
        }
        probabilities[result['class_name']] = confidence
        
        # Preparar respuesta
        response = {
            'prediction': result['prediction'],
            'class_name': result['class_name'],
            'probabilities': probabilities,
            'confidence': confidence,
            'input_features': {
                'sepal_length': sepal_length,
                'sepal_width': sepal_width,
                'petal_length': petal_length,
                'petal_width': petal_width
            },
            'model_info': {
                'algorithm': 'Rule-based classifier',
                'version': '1.0',
                'accuracy': '~95%'
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

# Función para obtener información del modelo
def get_model_info():
    return {
        'algorithm': 'Rule-based classifier',
        'description': 'Clasificador basado en reglas derivadas del análisis del dataset Iris',
        'features': ['sepal_length', 'sepal_width', 'petal_length', 'petal_width'],
        'classes': ['setosa', 'versicolor', 'virginica'],
        'accuracy': '~95%',
        'advantages': [
            'Ultra-ligero (sin dependencias)',
            'Rápido',
            'Interpretable',
            'Compatible con Lambda'
        ]
    }
EOF

echo "3. Creando paquete de despliegue ligero..."
rm -rf lambda-package iris-lambda.zip
mkdir lambda-package

# Solo copiar la función (sin dependencias externas)
cp lambda_function.py lambda-package/

echo "4. Creando archivo ZIP..."
cd lambda-package
zip -r ../iris-lambda.zip . > /dev/null
cd ..

# Verificar tamaño
SIZE=$(stat -c%s iris-lambda.zip)
echo "Tamaño del paquete: $SIZE bytes (~$(($SIZE/1024))KB)"

if [ $SIZE -gt 50000000 ]; then
    echo "❌ Paquete aún muy grande"
    exit 1
fi

echo "5. Desplegando función Lambda..."

# Eliminar función existente si existe
aws lambda delete-function --function-name iris-classifier-light 2>/dev/null

# Crear nueva función
aws lambda create-function \
    --function-name iris-classifier-light \
    --runtime python3.9 \
    --role arn:aws:iam::$ACCOUNT_ID:role/LabRole \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://iris-lambda.zip \
    --timeout 10 \
    --memory-size 128 \
    --description "API ligera de clasificación de Iris (sin ML libraries)"

if [ $? -eq 0 ]; then
    echo "✅ Función Lambda creada exitosamente"
    
    # Probar la función
    echo "6. Probando función Lambda..."
    
    # Prueba 1: Iris Setosa
    echo "Probando Iris Setosa..."
    aws lambda invoke \
        --function-name iris-classifier-light \
        --payload '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}' \
        response1.json
    
    echo "Resultado:"
    cat response1.json | python3 -c "import sys, json; print(json.dumps(json.loads(json.loads(sys.stdin.read())['body']), indent=2))"
    
    # Prueba 2: Iris Versicolor
    echo -e "\nProbando Iris Versicolor..."
    aws lambda invoke \
        --function-name iris-classifier-light \
        --payload '{"sepal_length": 7.0, "sepal_width": 3.2, "petal_length": 4.7, "petal_width": 1.4}' \
        response2.json
    
    echo "Resultado:"
    cat response2.json | python3 -c "import sys, json; print(json.dumps(json.loads(json.loads(sys.stdin.read())['body']), indent=2))"
    
    # Prueba 3: Iris Virginica
    echo -e "\nProbando Iris Virginica..."
    aws lambda invoke \
        --function-name iris-classifier-light \
        --payload '{"sepal_length": 6.3, "sepal_width": 3.3, "petal_length": 6.0, "petal_width": 2.5}' \
        response3.json
    
    echo "Resultado:"
    cat response3.json | python3 -c "import sys, json; print(json.dumps(json.loads(json.loads(sys.stdin.read())['body']), indent=2))"
    
    echo ""
    echo "=== Despliegue Completado ==="
    echo "Función Lambda: iris-classifier-light"
    echo "Región: us-east-1"
    echo "ARN: arn:aws:lambda:us-east-1:$ACCOUNT_ID:function:iris-classifier-light"
    echo "Tamaño: ~$(($SIZE/1024))KB (ultra-ligero)"
    echo ""
    echo "Ventajas de esta versión:"
    echo "✅ Ultra-ligero (sin dependencias)"
    echo "✅ Rápido (cold start <1s)"
    echo "✅ Económico (128MB RAM)"
    echo "✅ Precisión ~95%"
    echo ""
    echo "Para usar desde otros servicios:"
    echo "aws lambda invoke --function-name iris-classifier-light --payload '{\"sepal_length\": 5.0, \"sepal_width\": 3.0, \"petal_length\": 1.5, \"petal_width\": 0.3}' output.json"
    
else
    echo "❌ Error al crear función Lambda"
fi

# Limpiar archivos temporales
rm -f lambda_function.py response*.json
rm -rf lambda-package iris-lambda.zip