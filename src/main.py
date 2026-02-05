from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import os
from src.model import IrisClassifier
from src.schemas import IrisFeatures, PredictionResponse, ModelInfo, HealthResponse

# Inicializar FastAPI
app = FastAPI(
    title="Iris Classification API",
    description="API para clasificación de flores Iris usando Random Forest",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inicializar clasificador
classifier = IrisClassifier()

# Cargar o entrenar modelo al iniciar
MODEL_PATH = 'models/iris_model.joblib'

@app.on_event("startup")
async def startup_event():
    """Cargar o entrenar modelo al iniciar la aplicación"""
    if os.path.exists(MODEL_PATH):
        print("Cargando modelo existente...")
        classifier.load_model(MODEL_PATH)
        print("Modelo cargado exitosamente")
    else:
        print("Entrenando nuevo modelo...")
        classifier.train_model()
        classifier.save_model(MODEL_PATH)
        print("Modelo entrenado y guardado exitosamente")

@app.get("/", tags=["Health"])
async def root():
    """Endpoint raíz"""
    return {
        "message": "Iris Classification API",
        "version": "1.0.0",
        "endpoints": {
            "predict": "/predict (POST)",
            "model_info": "/model-info (GET)",
            "health": "/health (GET)"
        }
    }

@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    """Verificar estado del servicio"""
    return HealthResponse(
        status="healthy",
        model_loaded=classifier.model is not None,
        timestamp=datetime.now().isoformat()
    )

@app.post("/predict", response_model=PredictionResponse, tags=["Prediction"])
async def predict(features: IrisFeatures):
    """
    Realizar predicción de clasificación de Iris
    
    - **sepal_length**: Longitud del sépalo en cm
    - **sepal_width**: Ancho del sépalo en cm
    - **petal_length**: Longitud del pétalo en cm
    - **petal_width**: Ancho del pétalo en cm
    """
    try:
        # Convertir a lista
        feature_list = [
            features.sepal_length,
            features.sepal_width,
            features.petal_length,
            features.petal_width
        ]
        
        # Realizar predicción
        result = classifier.predict(feature_list)
        
        return PredictionResponse(**result)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en predicción: {str(e)}")

@app.get("/model-info", response_model=ModelInfo, tags=["Model"])
async def get_model_info():
    """
    Obtener información completa del modelo
    
    Retorna:
    - Algoritmo utilizado
    - Hiperparámetros
    - Métricas de evaluación (train y test)
    - Importancia de características
    - Información del dataset
    """
    if not classifier.model_info:
        raise HTTPException(status_code=404, detail="Información del modelo no disponible")
    
    return ModelInfo(**classifier.model_info)

@app.post("/retrain", tags=["Model"])
async def retrain_model(n_estimators: int = 100, max_depth: int = None):
    """
    Reentrenar el modelo con nuevos hiperparámetros
    
    - **n_estimators**: Número de árboles en el bosque
    - **max_depth**: Profundidad máxima de los árboles
    """
    try:
        print(f"Reentrenando modelo con n_estimators={n_estimators}, max_depth={max_depth}")
        model_info = classifier.train_model(n_estimators=n_estimators, max_depth=max_depth)
        classifier.save_model(MODEL_PATH)
        
        return {
            "message": "Modelo reentrenado exitosamente",
            "model_info": model_info
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al reentrenar: {str(e)}")