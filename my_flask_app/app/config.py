import os
from datetime import timedelta
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), '.env'))

class Config:
    # Flask
    SECRET_KEY = 'your-secret-key'
    
    # Database
    SQLALCHEMY_DATABASE_URI = 'sqlite:///app.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # JWT
    JWT_SECRET_KEY = 'jwt-secret-key'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=1)
    
    # Server
    HOST = os.getenv('HOST', 'localhost')
    PORT = int(os.getenv('PORT', 5000)) 