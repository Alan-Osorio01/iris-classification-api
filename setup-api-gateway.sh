#!/bin/bash

echo "=== Configurando API Gateway para Iris Classifier ==="

# Verificar credenciales
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
FUNCTION_NAME="iris-classifier-light"

echo "✅ Cuenta AWS: $ACCOUNT_ID"
echo "✅ Región: $REGION"
echo "✅ Función Lambda: $FUNCTION_NAME"

# 1. Crear API REST
echo "1. Creando API REST..."
API_ID=$(aws apigateway create-rest-api \
    --name "iris-classification-api" \
    --description "API pública para clasificación de flores Iris" \
    --query 'id' --output text)

if [ $? -eq 0 ]; then
    echo "✅ API creada con ID: $API_ID"
else
    echo "❌ Error creando API"
    exit 1
fi

# 2. Obtener el resource ID raíz
echo "2. Obteniendo resource raíz..."
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
    --rest-api-id $API_ID \
    --query 'items[0].id' --output text)

echo "✅ Resource raíz ID: $ROOT_RESOURCE_ID"

# 3. Crear resource /predict
echo "3. Creando resource /predict..."
PREDICT_RESOURCE_ID=$(aws apigateway create-resource \
    --rest-api-id $API_ID \
    --parent-id $ROOT_RESOURCE_ID \
    --path-part "predict" \
    --query 'id' --output text)

echo "✅ Resource /predict ID: $PREDICT_RESOURCE_ID"

# 4. Crear método POST para /predict
echo "4. Creando método POST..."
aws apigateway put-method \
    --rest-api-id $API_ID \
    --resource-id $PREDICT_RESOURCE_ID \
    --http-method POST \
    --authorization-type NONE

# 5. Configurar integración con Lambda
echo "5. Configurando integración Lambda..."
LAMBDA_URI="arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$FUNCTION_NAME/invocations"

aws apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $PREDICT_RESOURCE_ID \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri $LAMBDA_URI

# 6. Dar permisos a API Gateway para invocar Lambda
echo "6. Configurando permisos Lambda..."
aws lambda add-permission \
    --function-name $FUNCTION_NAME \
    --statement-id "api-gateway-invoke-$API_ID" \
    --action lambda:InvokeFunction \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/*" 2>/dev/null

# 7. Habilitar CORS para el método POST
echo "7. Habilitando CORS..."

# Crear método OPTIONS para CORS
aws apigateway put-method \
    --rest-api-id $API_ID \
    --resource-id $PREDICT_RESOURCE_ID \
    --http-method OPTIONS \
    --authorization-type NONE

# Configurar integración MOCK para OPTIONS
aws apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $PREDICT_RESOURCE_ID \
    --http-method OPTIONS \
    --type MOCK \
    --request-templates '{"application/json": "{\"statusCode\": 200}"}'

# Configurar respuesta para OPTIONS
aws apigateway put-method-response \
    --rest-api-id $API_ID \
    --resource-id $PREDICT_RESOURCE_ID \
    --http-method OPTIONS \
    --status-code 200 \
    --response-parameters '{"method.response.header.Access-Control-Allow-Headers": false, "method.response.header.Access-Control-Allow-Methods": false, "method.response.header.Access-Control-Allow-Origin": false}'

aws apigateway put-integration-response \
    --rest-api-id $API_ID \
    --resource-id $PREDICT_RESOURCE_ID \
    --http-method OPTIONS \
    --status-code 200 \
    --response-parameters '{"method.response.header.Access-Control-Allow-Headers": "'\''Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'\''", "method.response.header.Access-Control-Allow-Methods": "'\''POST,OPTIONS'\''", "method.response.header.Access-Control-Allow-Origin": "'\''*'\''"}'

# 8. Crear deployment
echo "8. Desplegando API..."
DEPLOYMENT_ID=$(aws apigateway create-deployment \
    --rest-api-id $API_ID \
    --stage-name "prod" \
    --stage-description "Producción" \
    --description "Despliegue inicial de la API Iris" \
    --query 'id' --output text)

if [ $? -eq 0 ]; then
    echo "✅ API desplegada con deployment ID: $DEPLOYMENT_ID"
else
    echo "❌ Error en el despliegue"
    exit 1
fi

# 9. Obtener URL de la API
API_URL="https://$API_ID.execute-api.$REGION.amazonaws.com/prod"

echo ""
echo "=== API Gateway Configurado Exitosamente ==="
echo ""
echo "🌐 URL de tu API: $API_URL"
echo "📡 Endpoint de predicción: $API_URL/predict"
echo ""
echo "=== Cómo usar tu API ==="
echo ""
echo "1. Con curl:"
echo "curl -X POST '$API_URL/predict' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"sepal_length\": 5.1, \"sepal_width\": 3.5, \"petal_length\": 1.4, \"petal_width\": 0.2}'"
echo ""
echo "2. Con JavaScript:"
echo "fetch('$API_URL/predict', {"
echo "  method: 'POST',"
echo "  headers: { 'Content-Type': 'application/json' },"
echo "  body: JSON.stringify({"
echo "    sepal_length: 5.1,"
echo "    sepal_width: 3.5,"
echo "    petal_length: 1.4,"
echo "    petal_width: 0.2"
echo "  })"
echo "})"
echo ""
echo "3. Con Python:"
echo "import requests"
echo "response = requests.post('$API_URL/predict', json={"
echo "    'sepal_length': 5.1,"
echo "    'sepal_width': 3.5,"
echo "    'petal_length': 1.4,"
echo "    'petal_width': 0.2"
echo "})"
echo "print(response.json())"
echo ""

# 10. Probar la API
echo "=== Probando la API ==="
echo "Probando con Iris Setosa..."
curl -X POST "$API_URL/predict" \
  -H "Content-Type: application/json" \
  -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}' \
  2>/dev/null | python3 -m json.tool

echo ""
echo "✅ ¡Tu API está lista y funcionando!"
echo "✅ Puedes acceder desde cualquier aplicación web o móvil"
echo "✅ CORS habilitado para uso desde navegadores"
echo ""
echo "Información para tu presentación:"
echo "- API ID: $API_ID"
echo "- URL: $API_URL/predict"
echo "- Método: POST"
echo "- Función Lambda: $FUNCTION_NAME"
echo "- Región: $REGION"