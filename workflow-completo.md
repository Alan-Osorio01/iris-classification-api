# Flujo de Trabajo: GitHub → AWS

## Opción 1: Despliegue Manual

### Paso 1: Desarrollo Local
```bash
# 1. Clonar repositorio
git clone https://github.com/TU_USUARIO/iris-classification-api.git
cd iris-classification-api

# 2. Crear entorno virtual
python -m venv venv
source venv/bin/activate

# 3. Instalar dependencias
pip install -r requirements.txt

# 4. Entrenar modelo
python train_model.py

# 5. Probar API localmente
uvicorn src.main:app --reload
```

### Paso 2: Subir Cambios a GitHub
```bash
git add .
git commit -m "Descripción de cambios"
git push origin main
```

### Paso 3: Desplegar a AWS
```bash
# Configurar AWS CLI con credenciales universitarias
aws configure

# Ejecutar script de despliegue
./aws/deploy.sh
```

## Opción 2: CI/CD Automático con GitHub Actions

### Configuración Inicial
1. Configurar secrets en GitHub (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
2. Crear workflow en `.github/workflows/deploy.yml`
3. Cada push a `main` despliega automáticamente

### Flujo Automático
```
Código → GitHub → GitHub Actions → AWS ECR → AWS ECS
```

## Opción 3: Desarrollo Híbrido (Recomendado)

### Para Desarrollo
- Trabajar localmente
- Probar con `docker-compose up`
- Subir cambios a GitHub

### Para Producción
- Usar script manual `./aws/deploy.sh`
- O configurar GitHub Actions para releases

## Comandos Útiles

### Git
```bash
# Ver estado
git status

# Ver historial
git log --oneline

# Crear rama para feature
git checkout -b feature/nueva-funcionalidad

# Mergear rama
git checkout main
git merge feature/nueva-funcionalidad
```

### AWS
```bash
# Ver servicios corriendo
aws ecs list-services --cluster iris-cluster

# Ver logs
aws logs tail /ecs/iris-classifier --follow

# Ver imágenes en ECR
aws ecr list-images --repository-name iris-classifier
```

### Docker
```bash
# Construir localmente
docker build -t iris-classifier .

# Probar localmente
docker run -p 8000:8000 iris-classifier

# Ver contenedores corriendo
docker ps
```