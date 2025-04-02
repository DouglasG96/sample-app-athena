# Use official Python base image
FROM python:3.11

# Set working directory
WORKDIR /app

# Copy the application code
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Expose FastAPI default port
EXPOSE 80

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
