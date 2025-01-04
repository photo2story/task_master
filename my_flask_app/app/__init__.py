from flask import Flask
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from .routes.auth_routes import auth_bp
from .routes.project_routes import project_bp
import datetime

def create_app():
    app = Flask(__name__)
    
    # CORS 설정
    CORS(app, resources={
        r"/*": {
            "origins": "*",
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })
    
    # JWT 설정
    app.config['JWT_SECRET_KEY'] = 'your-secret-key'  # 실제 운영에서는 환경변수로 관리
    app.config['JWT_ACCESS_TOKEN_EXPIRES'] = datetime.timedelta(days=1)
    jwt = JWTManager(app)
    
    # 블루프린트 등록
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(project_bp, url_prefix='/api/projects')
    
    return app