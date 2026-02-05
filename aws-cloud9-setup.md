# Configuración AWS Cloud9 para Iris Classification API

## ¿Qué es AWS Cloud9?

AWS Cloud9 es un IDE (entorno de desarrollo integrado) basado en la nube que incluye:
- ✅ Editor de código en el navegador
- ✅ Terminal integrado
- ✅ Credenciales AWS preconfiguradas
- ✅ Python, Node.js, y otras herramientas preinstaladas
- ✅ Integración directa con servicios AWS

## Paso 1: Crear Entorno Cloud9

### En AWS Academy:
1. Inicia tu **AWS Academy Learner Lab**
2. Haz clic en **"Start Lab"** y espera el círculo verde
3. Haz clic en **"AWS Console"**
4. En la consola AWS, busca **"Cloud9"**
5. Haz clic en **"Create environment"**

### Configuración del entorno:
- **Name**: `iris-ml-environment`
- **Description**: `Entorno para API de clasificación de Iris`
- **Environment type**: `New EC2 instance`
- **Instance type**: `t2.micro` (gratis en Academy)
- **Platform**: `Amazon Linux 2`
- **Cost-saving setting**: `After 30 minutes` (para ahorrar recursos)
- **Network**: Usar configuración por defecto

## Paso 2: Configurar el Proyecto en Cloud9

Una vez que Cloud9 esté listo:

### 1. Clonar el repositorio
```bash
# En el terminal de Cloud9
git clone https://github.com/Alan-Osorio01/iris-classification-api.git
cd iris-classification-api
```

### 2. Configurar entorno Python
```bash
# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt
```

### 3. Entrenar el modelo
```bash
python3 train_model.py
```

### 4. Ejecutar la API
```bash
# Ejecutar en Cloud9
uvicorn src.main:app --host 0.0.0.0 --port 8080
```

**Nota**: Cloud9 usa el puerto 8080 por defecto, no 8000.

## Paso 3: Probar la API en Cloud9

### Opción A: Preview en Cloud9
1. Con la API corriendo, haz clic en **"Preview"** en la barra superior
2. Selecciona **"Preview Running Application"**
3. Agrega `/docs` al final de la URL para ver Swagger UI

### Opción B: Terminal
```bash
# En otra terminal de Cloud9
curl http://localhost:8080/health

# Probar predicción
curl -X POST "http://localhost:8080/predict" \
     -H "Content-Type: application/json" \
     -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```

## Paso 4: Desplegar desde Cloud9

### Opción 1: AWS Lambda (Recomendado)

```bash
# Crear función Lambda desde Cloud9
# Las credenciales ya están configuradas automáticamente

# 1. Crear archivo lambda_function.py
cat > lambda_function.py << 'EOF'
import json
import joblib
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split

# Cargar modelo al inicializar
model_data = None

def load_model():
    global model_data
    if model_data is None:
        iris = load_iris()
        X_train, X_test, y_train, y_test = train_test_split(
            iris.data, iris.target, test_size=0.2, random_state=42
        )
        
        model = RandomForestClassifier(n_estimators=100, random_state=42)
        model.fit(X_train, y_train)
        
        model_data = {
            'model': model,
            'target_names': iris.target_names
        }
    
    return model_data

def lambda_handler(event, context):
    try:
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
            'body': json.dumps({'error': str(e)})
        }
EOF

# 2. Crear paquete de despliegue
mkdir lambda-package
cp lambda_function.py lambda-package/
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

echo "✅ Función Lambda creada"
```

### Opción 2: Elastic Beanstalk

```bash
# Instalar EB CLI en Cloud9
pip install awsebcli

# Inicializar aplicación
eb init iris-api --platform python-3.8 --region us-east-1

# Crear entorno
eb create iris-env --instance-type t2.micro

# Desplegar
eb deploy
```

## Paso 5: Configurar API Gateway (Para Lambda)

En la consola AWS:
1. Ve a **API Gateway**
2. Crea **REST API**
3. Crea recurso `/predict`
4. Crea método **POST**
5. Integra con la función Lambda `iris-classifier`
6. Habilita **CORS**
7. **Deploy API**

## Ventajas de Cloud9

### ✅ Preconfigurado
- Credenciales AWS automáticas
- No necesitas `aws configure`
- Herramientas preinstaladas

### ✅ Colaborativo
- Puedes compartir el entorno con compañeros
- Edición en tiempo real

### ✅ Integrado
- Terminal y editor en el mismo lugar
- Preview de aplicaciones web
- Debugging integrado

### ✅ Persistente
- Tu código se guarda automáticamente
- El entorno persiste entre sesiones

## Comandos Útiles en Cloud9

```bash
# Ver información de la instancia
curl http://169.254.169.254/latest/meta-data/instance-id

# Ver región actual
curl http://169.254.169.254/latest/meta-data/placement/region

# Verificar credenciales AWS
aws sts get-caller-identity

# Ver servicios disponibles
aws lambda list-functions
aws s3 ls
```

## Solución de Problemas

### Error de permisos
- Cloud9 usa automáticamente el rol `LabRole`
- No necesitas configurar credenciales manualmente

### Puerto ocupado
- Cloud9 usa puertos dinámicos
- Usa `--port 8080` o `--port 8081`

### Espacio en disco
- Cloud9 tiene espacio limitado
- Limpia archivos temporales regularmente

### Timeout del lab
- AWS Academy labs expiran
- Guarda tu trabajo en GitHub frecuentemente

## Workflow Recomendado

1. **Desarrollar** en Cloud9
2. **Probar** con Preview
3. **Commit** a GitHub desde Cloud9
4. **Desplegar** a Lambda/Beanstalk
5. **Documentar** resultados

¿Quieres que empecemos configurando Cloud9?