# Iris Classification API - Guía para AWS Cloud9

## Configuración Rápida en Cloud9

### Paso 1: Crear Entorno Cloud9
1. En AWS Academy, inicia tu **Learner Lab**
2. Ve a la consola AWS → **Cloud9**
3. **Create environment**:
   - Name: `iris-ml-environment`
   - Instance: `t2.micro`
   - Platform: `Amazon Linux 2`

### Paso 2: Configuración Automática
```bash
# En el terminal de Cloud9, ejecuta:
curl -sSL https://raw.githubusercontent.com/Alan-Osorio01/iris-classification-api/main/cloud9-quick-start.sh | bash
```

O manualmente:
```bash
git clone https://github.com/Alan-Osorio01/iris-classification-api.git
cd iris-classification-api
./cloud9-quick-start.sh
```

### Paso 3: Ejecutar la API
```bash
source venv/bin/activate
uvicorn src.main:app --host 0.0.0.0 --port 8080
```

### Paso 4: Probar la API
- **Preview**: Click "Preview" → "Preview Running Application"
- **Docs**: Agregar `/docs` a la URL del preview
- **Terminal**: 
  ```bash
  curl http://localhost:8080/health
  ```

## Despliegue a AWS Lambda

### Opción 1: Script Automático
```bash
./deploy-lambda-cloud9.sh
```

### Opción 2: Manual
```bash
# Crear función Lambda
aws lambda create-function \
    --function-name iris-classifier \
    --runtime python3.9 \
    --role arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/LabRole \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://iris-lambda.zip

# Probar función
aws lambda invoke \
    --function-name iris-classifier \
    --payload '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}' \
    response.json
```

## Endpoints Disponibles

### 1. Predicción (POST /predict)
```json
{
  "sepal_length": 5.1,
  "sepal_width": 3.5,
  "petal_length": 1.4,
  "petal_width": 0.2
}
```

### 2. Información del Modelo (GET /model-info)
Retorna algoritmo, hiperparámetros, métricas y más.

### 3. Estado (GET /health)
Verifica que el servicio esté funcionando.

## Ventajas de Cloud9

✅ **Sin configuración**: Credenciales AWS preconfiguradas  
✅ **IDE completo**: Editor + terminal + preview  
✅ **Colaborativo**: Comparte con compañeros  
✅ **Integrado**: Despliegue directo a AWS  

## Comandos Útiles

```bash
# Verificar credenciales
aws sts get-caller-identity

# Ver funciones Lambda
aws lambda list-functions

# Logs de Lambda
aws logs tail /aws/lambda/iris-classifier --follow

# Actualizar función
aws lambda update-function-code \
    --function-name iris-classifier \
    --zip-file fileb://iris-lambda.zip
```

## Solución de Problemas

### Puerto ocupado
```bash
# Usar puerto diferente
uvicorn src.main:app --host 0.0.0.0 --port 8081
```

### Error de permisos Lambda
- Verifica que el Lab esté activo
- El rol `LabRole` debe existir

### Espacio en disco
```bash
# Limpiar archivos temporales
rm -rf venv/__pycache__
pip cache purge
```

## Workflow Recomendado

1. **Desarrollar** en Cloud9
2. **Probar** con Preview
3. **Commit** a GitHub
4. **Desplegar** a Lambda
5. **Configurar** API Gateway (opcional)

¡Listo para usar Cloud9! 🚀