# Despliegue Optimizado para AWS Academy

Dado que AWS Academy tiene limitaciones, aquí tienes opciones más compatibles:

## Opción 1: AWS Lambda + API Gateway (Recomendado)

### Ventajas
- ✅ Siempre disponible en AWS Academy
- ✅ Serverless (no gestión de servidores)
- ✅ Escalamiento automático
- ✅ Costo muy bajo

### Crear función Lambda

```python
# lambda_function.py
import json
import joblib
import numpy as np
from io import BytesIO
import base64

# El modelo se carga una vez cuando se inicializa la función
model_data = None

def load_model():
    global model_data
    if model_data is None:
        # Aquí cargarías el modelo desde S3
        # Por simplicidad, incluimos un modelo pre-entrenado
        from sklearn.ensemble import RandomForestClassifier
        from sklearn.datasets import load_iris
        from sklearn.model_selection import train_test_split
        
        iris = load_iris()
        X_train, X_test, y_train, y_test = train_test_split(
            iris.data, iris.target, test_size=0.2, random_state=42
        )
        
        model = RandomForestClassifier(n_estimators=100, random_state=42)
        model.fit(X_train, y_train)
        
        model_data = {
            'model': model,
            'feature_names': iris.feature_names,
            'target_names': iris.target_names
        }
    
    return model_data

def lambda_handler(event, context):
    try:
        # Cargar modelo
        model_info = load_model()
        model = model_info['model']
        
        # Parsear request
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        # Extraer características
        features = [
            body['sepal_length'],
            body['sepal_width'],
            body['petal_length'],
            body['petal_width']
        ]
        
        # Predicción
        features_array = np.array(features).reshape(1, -1)
        prediction = model.predict(features_array)[0]
        probabilities = model.predict_proba(features_array)[0]
        
        # Respuesta
        response = {
            'prediction': int(prediction),
            'class_name': model_info['target_names'][prediction],
            'probabilities': {
                class_name: float(prob) 
                for class_name, prob in zip(model_info['target_names'], probabilities)
            }
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response)
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }
```

### Script de despliegue Lambda

```bash
#!/bin/bash
# deploy-lambda.sh

echo "=== Desplegando a AWS Lambda ==="

# 1. Crear paquete de despliegue
echo "1. Creando paquete..."
mkdir -p lambda-package
cp lambda_function.py lambda-package/

# 2. Instalar dependencias
pip install scikit-learn numpy -t lambda-package/

# 3. Crear ZIP
cd lambda-package
zip -r ../iris-lambda.zip .
cd ..

# 4. Crear función Lambda
aws lambda create-function \
    --function-name iris-classifier \
    --runtime python3.9 \
    --role arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/LabRole \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://iris-lambda.zip \
    --timeout 30 \
    --memory-size 512

# 5. Crear API Gateway
aws apigateway create-rest-api --name iris-api

echo "✅ Función Lambda creada"
echo "Configura API Gateway manualmente en la consola AWS"
```

## Opción 2: EC2 Simple

### Ventajas
- ✅ Control total
- ✅ Fácil de configurar
- ✅ Familiar si conoces servidores

### Script de despliegue EC2

```bash
#!/bin/bash
# deploy-ec2.sh

echo "=== Desplegando en EC2 ==="

# 1. Crear instancia EC2
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --instance-type t2.micro \
    --key-name vockey \
    --security-groups default \
    --user-data file://user-data.sh \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instancia creada: $INSTANCE_ID"

# 2. Esperar a que esté corriendo
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# 3. Obtener IP pública
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "✅ API disponible en: http://$PUBLIC_IP:8000"
```

### User data script

```bash
# user-data.sh
#!/bin/bash
yum update -y
yum install -y docker git

# Iniciar Docker
service docker start
usermod -a -G docker ec2-user

# Clonar repositorio
git clone https://github.com/TU_USUARIO/iris-classification-api.git /home/ec2-user/app
cd /home/ec2-user/app

# Construir y ejecutar
docker build -t iris-api .
docker run -d -p 8000:8000 iris-api

echo "API iniciada en puerto 8000"
```

## Opción 3: Desarrollo Local + Túnel

### Para desarrollo y demos

```bash
# 1. Ejecutar localmente
uvicorn src.main:app --host 0.0.0.0 --port 8000

# 2. Crear túnel público con ngrok
# Instalar ngrok: https://ngrok.com/
ngrok http 8000

# 3. Usar la URL pública que te da ngrok
```

## Recomendación

Para AWS Academy, te recomiendo:

1. **Desarrollo**: Local con Docker
2. **Demo/Presentación**: ngrok o Lambda
3. **Producción real**: EC2 simple

¿Cuál opción prefieres? Lambda es más "cloud-native" pero EC2 es más directo.