# Use official Python image
FROM python:3.11-slim

# Install curl and gnupg (needed for apt-key)
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https

# Install Microsoft ODBC Driver 18 for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    unixodbc \
    unixodbc-dev \
    libpq-dev \
    odbcinst

# Add Microsoft GPG key and repository
RUN mkdir -p /etc/apt/keyrings && \
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/11/prod stable main" > /etc/apt/sources.list.d/mssql-release.list

# Install ODBC driver
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18


# Set working directory
WORKDIR /app

# Copy code
COPY . .

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Expose port
ENV PORT=8080
EXPOSE 8080

# Start the app
CMD ["gunicorn", "main:app"]
