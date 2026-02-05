#!/bin/bash

echo "=== Configuración Rápida para AWS Cloud9 ==="
echo "Este script configura el proyecto Iris Classification en Cloud9"
echo ""

# Verificar que estamos en Cloud9
if [[ ! -d "/home/ec2-user" ]]; then
    echo "⚠️  Este script está diseñado para AWS Cloud9"
    echo "Si estás en Cloud9, continúa. Si no, usa la configuración local."
    read -p "¿Continuar? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "1. Clonando repositorio..."
if [ ! -d "iris-classification-api" ]; then
    git clone https://github.com/Alan-Osorio01/iris-classification-api.git
    cd iris-classification-api
else
    echo "   Repositorio ya existe, actualizando..."
    cd iris-classification-api
    git pull
fi

echo "2. Configurando entorno Python..."
python3 -m venv venv
source venv/bin/activate

echo "3. Instalando dependencias..."
pip install -r requirements.txt

echo "4. Entrenando modelo..."
python3 train_model.py

echo "5. Verificando configuración AWS..."
aws sts get-caller-identity

if [ $? -eq 0 ]; then
    echo "✅ Credenciales AWS configuradas correctamente"
else
    echo "❌ Error con credenciales AWS"
    echo "Verifica que el Lab esté iniciado en AWS Academy"
    exit 1
fi

echo ""
echo "=== Configuración Completada ==="
echo ""
echo "Para ejecutar la API:"
echo "  source venv/bin/activate"
echo "  uvicorn src.main:app --host 0.0.0.0 --port 8080"
echo ""
echo "Para ver la documentación:"
echo "  Preview -> Preview Running Application"
echo "  Agregar /docs al final de la URL"
echo ""
echo "Para desplegar a Lambda:"
echo "  ./deploy-lambda-cloud9.sh"
echo ""
echo "¡Listo para desarrollar! 🚀"