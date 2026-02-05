# Configuración GitHub para el Proyecto

## Paso 1: Crear Repositorio en GitHub

1. Ve a https://github.com
2. Haz clic en "New repository"
3. Nombre: `iris-classification-api`
4. Descripción: `API de clasificación de Iris con ML desplegada en AWS`
5. Público o Privado (según prefieras)
6. ✅ Add README file
7. ✅ Add .gitignore (Python)
8. Crear repositorio

## Paso 2: Clonar Repositorio Localmente

```bash
# Clonar tu repositorio
git clone https://github.com/Alan-Osorio01/iris-classification-api.git
cd iris-classification-api
```

## Paso 3: Configurar Git Localmente

```bash
# Configurar tu identidad (si no lo has hecho)
git config --global user.name "Alan Osorio"
git config --global user.email "alanloobo@gmail.com"

# Verificar configuración
git config --list
```

## Paso 4: Subir el Código del Proyecto

```bash
# Agregar todos los archivos
git add .

# Hacer commit
git commit -m "Initial commit: Iris classification API with AWS deployment"

# Subir a GitHub
git push origin main
```

## Paso 5: Configurar GitHub Actions para CI/CD (Opcional)

Crear archivo `.github/workflows/deploy.yml`:

```yaml
name: Deploy to AWS

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Login to Amazon ECR
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Build and push Docker image
      run: |
        docker build -t iris-classifier .
        docker tag iris-classifier:latest \$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/iris-classifier:latest
        docker push \$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/iris-classifier:latest
```

## Paso 6: Configurar Secrets en GitHub

1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Agregar secrets:
   - `AWS_ACCESS_KEY_ID`: Tu Access Key de AWS
   - `AWS_SECRET_ACCESS_KEY`: Tu Secret Key de AWS
   - `AWS_ACCOUNT_ID`: Tu Account ID de AWS

## Estructura Final del Repositorio

```
iris-classification-api/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── src/
│   ├── main.py
│   ├── model.py
│   └── schemas.py
├── aws/
│   ├── deploy.sh
│   └── task-definition.json
├── requirements.txt
├── Dockerfile
├── README.md
└── .gitignore
```