from pydantic import BaseModel, Field
from typing import Dict, List, Any

class IrisFeatures(BaseModel):
    sepal_length: float = Field(..., description="Longitud del sépalo en cm", ge=0)
    sepal_width: float = Field(..., description="Ancho del sépalo en cm", ge=0)
    petal_length: float = Field(..., description="Longitud del pétalo en cm", ge=0)
    petal_width: float = Field(..., description="Ancho del pétalo en cm", ge=0)

class PredictionResponse(BaseModel):
    prediction: int = Field(..., description="Clase predicha (0, 1, 2)")
    class_name: str = Field(..., description="Nombre de la clase predicha")
    probabilities: Dict[str, float] = Field(..., description="Probabilidades por clase")

class ModelInfo(BaseModel):
    algorithm: str = Field(..., description="Algoritmo utilizado")
    hyperparameters: Dict[str, Any] = Field(..., description="Hiperparámetros del modelo")
    metrics: Dict[str, Any] = Field(..., description="Métricas de evaluación")
    feature_importance: Dict[str, float] = Field(..., description="Importancia de características")
    training_date: str = Field(..., description="Fecha de entrenamiento")
    dataset_info: Dict[str, Any] = Field(..., description="Información del dataset")

class HealthResponse(BaseModel):
    status: str = Field(..., description="Estado del servicio")
    model_loaded: bool = Field(..., description="Si el modelo está cargado")
    timestamp: str = Field(..., description="Timestamp de la respuesta")