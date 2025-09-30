#!/usr/bin/env python3
"""
AGRICHAIN Backend Startup Script
================================
This script tests and starts the FastAPI backend for Aadhaar verification.
"""

import sys
import os
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent.absolute()
sys.path.insert(0, str(backend_dir))

print("🔐 AGRICHAIN Aadhaar Verification Backend")
print("=" * 50)
print(f"📁 Backend Directory: {backend_dir}")
print(f"🐍 Python Version: {sys.version}")

# Test imports
try:
    print("\n🧪 Testing imports...")
    
    # Test standard library imports
    import asyncio
    import json
    import hashlib
    from datetime import datetime, timedelta
    print("  ✅ Standard library imports successful")
    
    # Test third-party imports
    import fastapi
    import uvicorn
    import motor.motor_asyncio
    import pymongo
    import cryptography
    import jwt
    import httpx
    print("  ✅ Third-party imports successful")
    
    # Test main application import
    import main
    print("  ✅ Main application import successful")
    
    # Test FastAPI app
    app = main.app
    print(f"  ✅ FastAPI app loaded: {app}")
    
    # Test database connection (without actually connecting)
    print("\n🔧 Configuration check...")
    if hasattr(main, 'MONGODB_URI'):
        print(f"  📊 MongoDB URI configured: {main.MONGODB_URI}")
    
    print("\n🚀 All checks passed! Starting server...")
    print("🌐 Server will be available at: http://localhost:8000")
    print("📚 API Documentation: http://localhost:8000/docs")
    print("💾 Database: MongoDB (configure in .env)")
    print("\n⚡ Starting uvicorn server...")
    
    # Start the server
    if __name__ == "__main__":
        uvicorn.run(
            "main:app",
            host="0.0.0.0",
            port=8000,
            reload=True,
            reload_dirs=[str(backend_dir)]
        )
        
except ImportError as e:
    print(f"❌ Import Error: {e}")
    print("\n📦 Missing dependencies. Please install:")
    print("pip install -r requirements.txt")
    sys.exit(1)
    
except Exception as e:
    print(f"❌ Error: {e}")
    print("\n🔍 Please check your configuration and try again.")
    sys.exit(1)