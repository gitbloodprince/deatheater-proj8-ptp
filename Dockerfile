# Stage 1: SQL tools base (optional)
FROM mcr.microsoft.com/mssql/server:2022-latest AS sqltools

# Stage 2: Python app
FROM python:3.11-slim

# Set environment variables
ENV ACCEPT_EULA=Y
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/mssql-tools18/bin:$PATH"

# Install system dependencies and ODBC Driver 18
RUN apt-get update && \
    apt-get install -y curl gnupg ca-certificates apt-transport-https && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/11/prod bullseye main" \
        > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Optional: Copy SQL tools from Stage 1
COPY --from=sqltools /opt/mssql-tools18 /opt/mssql-tools18

# Set working directory
WORKDIR /app

# Copy application code
COPY . .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Set port and expose it
ENV PORT=8080
EXPOSE 8080

# Start the app with Gunicorn
CMD ["gunicorn", "main:app"]

# # Stage 1: SQL tools base (optional)
# FROM mcr.microsoft.com/mssql/server:2022-latest AS sqltools

# # Stage 2: Python app
# FROM python:3.11-slim

# # Set environment variables
# ENV ACCEPT_EULA=Y
# ENV DEBIAN_FRONTEND=noninteractive
# ENV PATH="/opt/mssql-tools18/bin:$PATH"

# # Install system dependencies and ODBC Driver 18
# RUN apt-get update && \
#     apt-get install -y curl gnupg ca-certificates apt-transport-https unixodbc-dev && \
#     mkdir -p /etc/apt/keyrings && \
#     curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg && \
#     echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/11/prod bullseye main" \
#         > /etc/apt/sources.list.d/mssql-release.list && \
#     apt-get update && \
#     ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
#     apt-get clean && rm -rf /var/lib/apt/lists/*


# # Optional: Copy SQL tools from Stage 1
# COPY --from=sqltools /opt/mssql-tools18 /opt/mssql-tools18

# # Set working directory
# WORKDIR /app

# # Copy application code
# COPY . .

# # Install Python dependencies
# RUN pip install --upgrade pip && \
#     pip install --no-cache-dir -r requirements.txt

# # Set port and expose it
# ENV PORT=8080
# EXPOSE 8080

# # Start the app with Gunicorn
# CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]

