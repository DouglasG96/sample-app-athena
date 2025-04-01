
# 🚀 FastAPI MySQL CRUD API

This project provides a FastAPI-based CRUD API for managing users in a MySQL database.

---

## 📋 Prerequisites

Before starting, ensure you have the following installed:

- **Python 3.8+** - [Download Python](https://www.python.org/downloads/)
- **Docker** - [Download Docker](https://www.docker.com/get-started/)
- **AWS CLI** - [Download AWS CLI](https://aws.amazon.com/cli/)
- **GitHub Actions setup**

---

## 🛠️ Setup and Run Locally

### 1. Install Dependencies
Ensure you have `pip` installed, then run:
```bash
pip install fastapi uvicorn sqlalchemy pymysql
```

### 2. Set Up Environment Variables
Create a `.env` file with the following values:
```bash
DB_HOST=<your-db-host>
DB_PORT=3306
DB_USER=<your-db-user>
DB_PASSWORD=<your-db-password>
DB_NAME=<your-db-name>
```

### 3. Run the API
Start the FastAPI server using:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

---

## 📡 API Endpoints

### Create User
```bash
curl -X POST "http://localhost:8000/users/" -H "Content-Type: application/json" -d '{"name": "John Doe", "email": "john@example.com"}'
```

### Get User
```bash
curl -X GET "http://localhost:8000/users/1"
```

### Update User
```bash
curl -X PUT "http://localhost:8000/users/1" -H "Content-Type: application/json" -d '{"name": "John Updated", "email": "john.updated@example.com"}'
```

### Delete User
```bash
curl -X DELETE "http://localhost:8000/users/1"
```

---

## 🚀 Deployment to AWS ECS via GitHub Actions

This project includes a GitHub Actions workflow to automate deployment to AWS ECS.

### 🔧 GitHub Actions Workflow

#### 1. **Configure AWS Credentials**
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v1
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}
```

#### 2. **Login to Amazon ECR**
```yaml
- name: Login to Amazon ECR
  id: login-ecr
  uses: aws-actions/amazon-ecr-login@v1
```

#### 3. **Build, Tag, and Push Image to Amazon ECR**
```yaml
- name: Build, tag, and push image to Amazon ECR
  id: build-image
  env:
    ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
    IMAGE_TAG: ${{ github.sha }}
    REPO: ${{secrets.REPO}}
  run: |
    # Build a docker container and push it to ECR so that it can be deployed to ECS.
    docker build -f Dockerfile.prd -t $ECR_REGISTRY/$REPO:$IMAGE_TAG .
    echo "image=$ECR_REGISTRY/$REPO:$IMAGE_TAG"
    docker push $ECR_REGISTRY/$REPO:$IMAGE_TAG
    echo "image=$ECR_REGISTRY/$REPO:$IMAGE_TAG" >> $GITHUB_OUTPUT
```

#### 4. **Download Task Definition**
```yaml
- name: Download task definition
  run: |
    aws ecs describe-task-definition --task-definition ${{ secrets.ECS_TASK_DEFINITION }}     --query taskDefinition > task-definition.json
```

#### 5. **Update ECS Task Definition with New Image**
```yaml
- name: Fill in the new image ID in the Amazon ECS task definition
  id: task-def
  uses: aws-actions/amazon-ecs-render-task-definition@v1
  with:
    task-definition: task-definition.json
    container-name: ${{ secrets.CONTAINER_NAME }}
    image: ${{ steps.build-image.outputs.image }}
```

#### 6. **Deploy to ECS**
```yaml
- name: Deploy Amazon ECS task definition
  uses: aws-actions/amazon-ecs-deploy-task-definition@v1
  with:
    task-definition: ${{ steps.task-def.outputs.task-definition }}
    service: ${{ secrets.ECS_SERVICE }}
    cluster: ${{ secrets.ECS_CLUSTER }}
    wait-for-service-stability: true
```

---

## 🙏 Acknowledgments

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy Documentation](https://www.sqlalchemy.org/)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)

Happy coding! 🎉
