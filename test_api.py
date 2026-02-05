#!/usr/bin/env python3
"""
Script para probar la API de clasificación de Iris
"""

import requests
import json

# URL base de la API
BASE_URL = "http://localhost:8000"

def test_health():
    """Probar endpoint de salud"""
    print("=== Probando /health ===")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_model_info():
    """Probar endpoint de información del modelo"""
    print("=== Probando /model-info ===")
    response = requests.get(f"{BASE_URL}/model-info")
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Algoritmo: {data['algorithm']}")
        print(f"Precisión en prueba: {data['metrics']['test_accuracy']:.4f}")
        print(f"Hiperparámetros: {data['hyperparameters']}")
    else:
        print(f"Error: {response.text}")
    print()

def test_prediction():
    """Probar endpoint de predicción"""
    print("=== Probando /predict ===")
    
    # Ejemplos de diferentes clases de Iris
    test_cases = [
        {
            "name": "Iris Setosa",
            "features": {
                "sepal_length": 5.1,
                "sepal_width": 3.5,
                "petal_length": 1.4,
                "petal_width": 0.2
            }
        },
        {
            "name": "Iris Versicolor",
            "features": {
                "sepal_length": 7.0,
                "sepal_width": 3.2,
                "petal_length": 4.7,
                "petal_width": 1.4
            }
        },
        {
            "name": "Iris Virginica",
            "features": {
                "sepal_length": 6.3,
                "sepal_width": 3.3,
                "petal_length": 6.0,
                "petal_width": 2.5
            }
        }
    ]
    
    for test_case in test_cases:
        print(f"Probando {test_case['name']}:")
        response = requests.post(
            f"{BASE_URL}/predict",
            json=test_case['features']
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"  Predicción: {result['class_name']}")
            print(f"  Probabilidades:")
            for class_name, prob in result['probabilities'].items():
                print(f"    {class_name}: {prob:.4f}")
        else:
            print(f"  Error: {response.text}")
        print()

def main():
    """Ejecutar todas las pruebas"""
    print("Iniciando pruebas de la API...")
    print("Asegúrate de que la API esté corriendo en http://localhost:8000")
    print()
    
    try:
        test_health()
        test_model_info()
        test_prediction()
        print("¡Todas las pruebas completadas!")
        
    except requests.exceptions.ConnectionError:
        print("Error: No se puede conectar a la API.")
        print("Asegúrate de que esté corriendo con: uvicorn src.main:app --reload")

if __name__ == "__main__":
    main()