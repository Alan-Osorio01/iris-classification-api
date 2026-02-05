import pandas as pd
import numpy as np
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.preprocessing import StandardScaler
import joblib
import json
from datetime import datetime

class IrisClassifier:
    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()
        self.model_info = {}
        self.feature_names = ['sepal_length', 'sepal_width', 'petal_length', 'petal_width']
        self.target_names = ['setosa', 'versicolor', 'virginica']
        
    def load_data(self):
        """Cargar el dataset de Iris"""
        iris = load_iris()
        X = pd.DataFrame(iris.data, columns=self.feature_names)
        y = pd.Series(iris.target)
        return X, y
    
    def train_model(self, n_estimators=100, max_depth=None, random_state=42):
        """Entrenar el modelo con hiperparámetros especificados"""
        # Cargar datos
        X, y = self.load_data()
        
        # División train/test
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=random_state, stratify=y
        )
        
        # Escalar características
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Entrenar modelo
        self.model = RandomForestClassifier(
            n_estimators=n_estimators,
            max_depth=max_depth,
            random_state=random_state
        )
        self.model.fit(X_train_scaled, y_train)
        
        # Predicciones
        y_train_pred = self.model.predict(X_train_scaled)
        y_test_pred = self.model.predict(X_test_scaled)
        
        # Métricas
        train_accuracy = accuracy_score(y_train, y_train_pred)
        test_accuracy = accuracy_score(y_test, y_test_pred)
        
        # Guardar información del modelo
        self.model_info = {
            'algorithm': 'Random Forest',
            'hyperparameters': {
                'n_estimators': n_estimators,
                'max_depth': max_depth,
                'random_state': random_state
            },
            'metrics': {
                'train_accuracy': float(train_accuracy),
                'test_accuracy': float(test_accuracy),
                'classification_report': classification_report(y_test, y_test_pred, 
                                                             target_names=self.target_names, 
                                                             output_dict=True)
            },
            'feature_importance': dict(zip(self.feature_names, 
                                         self.model.feature_importances_.tolist())),
            'training_date': datetime.now().isoformat(),
            'dataset_info': {
                'total_samples': len(X),
                'train_samples': len(X_train),
                'test_samples': len(X_test),
                'features': self.feature_names,
                'classes': self.target_names
            }
        }
        
        return self.model_info
    
    def predict(self, features):
        """Realizar predicción"""
        if self.model is None:
            raise ValueError("Modelo no entrenado")
        
        # Convertir a array si es necesario
        if isinstance(features, list):
            features = np.array(features).reshape(1, -1)
        elif len(features.shape) == 1:
            features = features.reshape(1, -1)
        
        # Escalar características
        features_scaled = self.scaler.transform(features)
        
        # Predicción
        prediction = self.model.predict(features_scaled)[0]
        probabilities = self.model.predict_proba(features_scaled)[0]
        
        return {
            'prediction': int(prediction),
            'class_name': self.target_names[prediction],
            'probabilities': {
                class_name: float(prob) 
                for class_name, prob in zip(self.target_names, probabilities)
            }
        }
    
    def save_model(self, filepath='models/iris_model.joblib'):
        """Guardar modelo entrenado"""
        import os
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        
        model_data = {
            'model': self.model,
            'scaler': self.scaler,
            'model_info': self.model_info,
            'feature_names': self.feature_names,
            'target_names': self.target_names
        }
        joblib.dump(model_data, filepath)
        
    def load_model(self, filepath='models/iris_model.joblib'):
        """Cargar modelo entrenado"""
        model_data = joblib.load(filepath)
        self.model = model_data['model']
        self.scaler = model_data['scaler']
        self.model_info = model_data['model_info']
        self.feature_names = model_data['feature_names']
        self.target_names = model_data['target_names']