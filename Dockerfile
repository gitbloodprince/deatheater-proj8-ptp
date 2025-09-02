# Use official Python image
FROM python:3.11-slim

# Set environment variables
ENV ACCEPT_EULA=Y
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/mssql-tools18/bin:$PATH"

# Install system dependencies and Microsoft GPG key
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    unixodbc \
    unixodbc-dev \
    libpq-dev \
    odbcinst \
    && mkdir -p /etc/apt/keyrings \
    && curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/11/prod stable main" > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update && apt-get install -y msodbcsql18 mssql-tools18 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy application code
COPY . .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Expose port
ENV PORT=8080
EXPOSE 8080

# Start the app
CMD ["gunicorn", "main:app"]
