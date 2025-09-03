# from flask import Flask, g
# import os
# import pyodbc
# from .routes import bp

# def create_app():
#     app = Flask(__name__)

#     # Environment-based DB config
#     server = os.environ.get('DB_SERVER')
#     database = os.environ.get('DB_NAME')
#     username = os.environ.get('DB_USER')
#     password = os.environ.get('DB_PASSWORD')
#     driver = os.environ.get('DB_DRIVER', 'ODBC Driver 18 for SQL Server')

#     # Correct connection string for ODBC Driver 18
#     conn_str = (
#         f"DRIVER={{{driver}}};"
#         f"SERVER={server};"
#         f"DATABASE={database};"
#         f"UID={username};"
#         f"PWD={password};"
#         "Encrypt=yes;"
#         "TrustServerCertificate=no;"
#         "Connection Timeout=30;"
#     )

#     # Attach connection before each request
#     @app.before_request
#     def before_request():
#         g.conn = pyodbc.connect(conn_str)
#         g.cursor = g.conn.cursor()

#     # Close connection after each request
#     @app.teardown_request
#     def teardown_request(exception):
#         cursor = getattr(g, 'cursor', None)
#         conn = getattr(g, 'conn', None)
#         if cursor:
#             cursor.close()
#         if conn:
#             conn.close()

#     # Register routes
#     app.register_blueprint(bp)

#     return app

from flask import Flask, g, jsonify
import os
import pyodbc
from .routes import bp

def create_app():
    app = Flask(__name__)

    # Environment-based DB config
    server = os.environ.get('DB_SERVER')
    database = os.environ.get('DB_NAME')
    username = os.environ.get('DB_USER')
    password = os.environ.get('DB_PASSWORD')
    driver = os.environ.get('DB_DRIVER', 'ODBC Driver 18 for SQL Server')

    # Build connection string
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"UID={username};"
        f"PWD={password};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=30;"
    )

    # Log sanitized connection string for debugging
    print("🔧 DB connection string:", conn_str.replace(password or "", "****"))

    # Attach connection before each request
    @app.before_request
    def before_request():
        try:
            g.conn = pyodbc.connect(conn_str)
            g.cursor = g.conn.cursor()
        except Exception as e:
            import traceback
            print("❌ pyodbc.connect() failed:", repr(e))
            traceback.print_exc()
            return jsonify({"error": str(e)}), 500

    # Close connection after each request
    @app.teardown_request
    def teardown_request(exception):
        cursor = getattr(g, 'cursor', None)
        conn = getattr(g, 'conn', None)
        if cursor:
            cursor.close()
        if conn:
            conn.close()

    # Register routes
    app.register_blueprint(bp)

    # Optional: health check route
    @app.route("/health")
    def health():
        return jsonify({"status": "ok"})

    return app

