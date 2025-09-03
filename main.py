import os
from dotenv import load_dotenv
load_dotenv()


try:
    from app import create_app
    app = create_app()
    print("✅ App created successfully")
except Exception as e:
    print("❌ App failed to start:", e)
    import traceback
    traceback.print_exc()
    raise  # re-raise to ensure Gunicorn sees the failure

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
