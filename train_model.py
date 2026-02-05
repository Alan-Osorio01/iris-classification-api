#!/usr/bin/env python3
"""
Script para entrenar el modelo de clasificación de Iris
"""

from src.model import IrisClassifier
import json

def main():
    print("Iniciando entrenamiento del modelo de Iris...")
    
    # Crear clasificador
    classifier = IrisClassifier()
    
    # Entrenar modelo
    model_info = classifier.train_model(
        n_estimators=100,
        max_depth=None,
        random_state=42
    )
    
    # Guardar modelo
    classifier.save_model('models/iris_model.joblib')
    
    # Mostrar información
    print("\n=== INFORMACIÓN DEL MODELO ===")
    print(f"Algoritmo: {model_info['algorithm']}")
    print(f"Hiperparámetros: {model_info['hyperparameters']}")
    print(f"Precisión en entrenamiento: {model_info['metrics']['train_accuracy']:.4f}")
    print(f"Precisión en prueba: {model_info['metrics']['test_accuracy']:.4f}")
    
    print("\n=== IMPORTANCIA DE CARACTERÍSTICAS ===")
    for feature, importance in model_info['feature_importance'].items():
        print(f"{feature}: {importance:.4f}")
    
    print("\n=== INFORMACIÓN DEL DATASET ===")
    dataset_info = model_info['dataset_info']
    print(f"Total de muestras: {dataset_info['total_samples']}")
    print(f"Muestras de entrenamiento: {dataset_info['train_samples']}")
    print(f"Muestras de prueba: {dataset_info['test_samples']}")
    print(f"Características: {dataset_info['features']}")
    print(f"Clases: {dataset_info['classes']}")
    
    # Guardar información en JSON
    with open('model_info.json', 'w') as f:
        json.dump(model_info, f, indent=2)
    
    print(f"\nModelo guardado en: models/iris_model.joblib")
    print(f"Información guardada en: model_info.json")
    print("¡Entrenamiento completado!")

if __name__ == "__main__":
    main()