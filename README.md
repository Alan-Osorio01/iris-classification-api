# Iris Classification API

API de clasificación de flores Iris usando Random Forest, desplegada en AWS con FastAPI.

## Características

- **Modelo**: Random Forest Classifier para clasificación de especies de Iris
- **API REST**: Endpoints para predicción e información del modelo
- **Métricas**: Evaluación completa con precisión, recall, F1-score
- **Despliegue**: Containerizado con Docker y desplegable en AWS ECS
- **Documentación**: API docs automática con Swagger/OpenAPI

## Estructura del Proyecto

```
├── src/
│   ├── main.py          # API FastAPI
│   ├── model.py         # Modelo de clasificación
│   └── schemas.py       # Esquemas Pydantic
├── aws/
│   ├── deploy.sh        # Script de despliegue
│   ├── task-definition.json
│   └── setup-aws.md     # Guía de configuración AWS
├── train_model.py       # Script de entrenamiento
├── test_api.py         # Script de pruebas
├── requirements.txt
├── Dockerfile
└── docker-compose.yml
```

## Instalación Local

### 1. Clonar y configurar entorno
```bash
# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Instalar dependencias
pip install -r requirements.txt
```

### 2. Entrenar modelo
```bash
python train_model.py
```

### 3. Ejecutar API
```bash
uvicorn src.main:app --reload
```

La API estará disponible en: http://localhost:8000

## Endpoints de la API

### POST /predict
Realizar predicción de clasificación
```json
{
  "sepal_length": 5.1,
  "sepal_width": 3.5,
  "petal_length": 1.4,
  "petal_width": 0.2
}
```

**Respuesta:**
```json
{
  "prediction": 0,
  "class_name": "setosa",
  "probabilities": {
    "setosa": 0.95,
    "versicolor": 0.03,
    "virginica": 0.02
  }
}
```

### GET /model-info
Obtener información completa del modelo
```json
{
  "algorithm": "Random Forest",
  "hyperparameters": {
    "n_estimators": 100,
    "max_depth": null,
    "random_state": 42
  },
  "metrics": {
    "train_accuracy": 1.0,
    "test_accuracy": 0.9667,
    "classification_report": {...}
  },
  "feature_importance": {
    "sepal_length": 0.1234,
    "sepal_width": 0.0987,
    "petal_length": 0.4321,
    "petal_width": 0.3458
  }
}
```

### GET /health
Verificar estado del servicio

## Pruebas

```bash
# Probar API localmente
python test_api.py

# Con curl
curl -X POST "http://localhost:8000/predict" \
     -H "Content-Type: application/json" \
     -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```

## Despliegue con Docker

### Local
```bash
# Construir y ejecutar
docker-compose up --build

# Solo ejecutar
docker-compose up -d
```

### Producción
```bash
# Construir imagen
docker build -t iris-classifier .

# Ejecutar contenedor
docker run -p 8000:8000 iris-classifier
```

## Despliegue en AWS

### 1. Configurar AWS
Seguir la guía en `aws/setup-aws.md` para:
- Configurar credenciales AWS
- Verificar permisos necesarios
- Configurar VPC y subnets

### 2. Ejecutar despliegue
```bash
# Hacer ejecutable el script
chmod +x aws/deploy.sh

# Editar configuración
nano aws/deploy.sh  # Actualizar ACCOUNT_ID y configuración

# Desplegar
./aws/deploy.sh
```

### 3. Verificar despliegue
```bash
# Ver estado del servicio
aws ecs describe-services --cluster iris-cluster --services iris-service

# Ver logs
aws logs tail /ecs/iris-classifier --follow
```

## Información del Modelo

### Dataset
- **Fuente**: Iris dataset de scikit-learn
- **Muestras**: 150 (50 por clase)
- **Características**: 4 (sepal_length, sepal_width, petal_length, petal_width)
- **Clases**: 3 (setosa, versicolor, virginica)

### Algoritmo
- **Modelo**: Random Forest Classifier
- **Hiperparámetros por defecto**:
  - n_estimators: 100
  - max_depth: None
  - random_state: 42

### Métricas Típicas
- **Precisión en entrenamiento**: ~100%
- **Precisión en prueba**: ~96-97%
- **F1-Score**: >0.95 para todas las clases

## Documentación API

Una vez ejecutando la API, visitar:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## Conexión con AWS Educate

Si tu universidad te proporcionó credenciales de AWS Educate:

1. **Obtener credenciales**:
   - Acceder al AWS Educate Classroom
   - Hacer clic en "AWS Console"
   - Copiar las credenciales temporales

2. **Configurar localmente**:
   ```bash
   export AWS_ACCESS_KEY_ID="tu-access-key"
   export AWS_SECRET_ACCESS_KEY="tu-secret-key"
   export AWS_SESSION_TOKEN="tu-session-token"  # Solo para credenciales temporales
   export AWS_DEFAULT_REGION="us-east-1"
   ```

3. **Verificar conexión**:
   ```bash
   aws sts get-caller-identity
   ```

## Solución de Problemas

### Error de permisos AWS
- Verificar credenciales con `aws sts get-caller-identity`
- Contactar administrador de AWS de la universidad

### Error de conexión local
- Verificar que el puerto 8000 esté libre
- Revisar logs con `docker-compose logs`

### Error de modelo no encontrado
- Ejecutar `python train_model.py` primero
- Verificar que existe el directorio `models/`

## Contribuir

1. Fork del repositorio
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request