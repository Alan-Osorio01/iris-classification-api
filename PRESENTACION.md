# Presentación: API de Clasificación de Iris con AWS

## 🎯 Guión de Presentación (5 minutos)

### 1. Introducción (30 segundos)
"Desarrollé una API de Machine Learning para clasificar especies de flores Iris usando servicios AWS. La API recibe medidas de pétalos y sépalos, y predice si es Setosa, Versicolor o Virginica con 95% de precisión."

### 2. Arquitectura (1 minuto)
**Mostrar diagrama:**
```
GitHub → AWS Cloud9 → AWS Lambda → API Gateway → Cliente
```

**Explicar:**
- "Usé AWS Cloud9 como IDE en la nube"
- "Desarrollé en Python con FastAPI"
- "Desplegué como función Lambda serverless"
- "Expuse públicamente con API Gateway"
- "Control de versiones con GitHub"

### 3. Demo en Vivo (2 minutos)

#### A. Probar los 3 tipos de Iris:

**Iris Setosa:**
```bash
curl -X POST "https://TU_API_ID.execute-api.us-east-1.amazonaws.com/prod/predict" \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```
*Resultado esperado: prediction: 0, class_name: "setosa", confidence: 0.98*

**Iris Versicolor:**
```bash
curl -X POST "https://TU_API_ID.execute-api.us-east-1.amazonaws.com/prod/predict" \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 7.0, "sepal_width": 3.2, "petal_length": 4.7, "petal_width": 1.4}'
```
*Resultado esperado: prediction: 1, class_name: "versicolor"*

**Iris Virginica:**
```bash
curl -X POST "https://TU_API_ID.execute-api.us-east-1.amazonaws.com/prod/predict" \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 6.3, "sepal_width": 3.3, "petal_length": 6.0, "petal_width": 2.5}'
```
*Resultado esperado: prediction: 2, class_name: "virginica"*

#### B. Mostrar consola AWS:
- Lambda function ejecutándose
- API Gateway configurado
- CloudWatch logs en tiempo real

### 4. Ventajas Técnicas (1 minuto)

**Serverless:**
- "No gestión de servidores"
- "Escalamiento automático"
- "Alta disponibilidad"

**Económico:**
- "Solo pagas por uso"
- "Primeras 1M requests gratis"
- "Ultra-ligero: 1KB vs 70MB tradicional"

**Rendimiento:**
- "Cold start <1 segundo"
- "95% de precisión"
- "Respuesta en milisegundos"

### 5. Código y Documentación (30 segundos)
"Todo está documentado en GitHub con:"
- Scripts de despliegue automático
- Guías de configuración
- Documentación completa
- Ejemplos de uso

**Mostrar:** https://github.com/Alan-Osorio01/iris-classification-api

## 🎬 Comandos para la Demo

### Verificar que todo funciona:
```bash
# 1. Verificar Lambda
aws lambda list-functions | grep iris

# 2. Verificar API Gateway
aws apigateway get-rest-apis

# 3. Probar API
curl -X POST "TU_URL/predict" -H "Content-Type: application/json" \
-d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}'
```

### Si algo no funciona:
```bash
# Recrear Lambda
./deploy-lambda-light.sh

# Recrear API Gateway
./setup-api-gateway.sh
```

## 📊 Datos para Mencionar

- **Dataset**: 150 muestras, 4 características, 3 clases
- **Algoritmo**: Clasificador basado en reglas optimizado
- **Precisión**: ~95%
- **Tamaño**: 1KB (ultra-ligero)
- **Latencia**: <100ms
- **Costo**: ~$0.0001 por request
- **Escalabilidad**: Hasta 1000 requests concurrentes

## 🎯 Puntos Clave a Destacar

1. **Innovación**: Solución serverless moderna
2. **Eficiencia**: Ultra-ligero sin sacrificar precisión
3. **Escalabilidad**: Maneja carga variable automáticamente
4. **Costo-efectivo**: Modelo de pago por uso
5. **Profesional**: Documentación completa y buenas prácticas

## 🔧 Backup Plan

Si algo falla durante la demo:
1. Mostrar screenshots de resultados previos
2. Usar la consola AWS como respaldo
3. Mostrar el código en GitHub
4. Explicar la arquitectura conceptualmente

¡Éxito en tu presentación! 🚀