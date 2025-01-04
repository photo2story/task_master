from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        
        # TODO: 실제 인증 로직 구현
        if email and password:
            access_token = create_access_token(identity=email)
            return jsonify({
                'token': access_token,
                'user': {
                    'email': email,
                    'name': 'Test User',
                    'role': 'admin'
                }
            }), 200
        
        return jsonify({'message': 'Invalid credentials'}), 401
        
    except Exception as e:
        return jsonify({'message': str(e)}), 500

@auth_bp.route('/validate', methods=['GET'])
@jwt_required()
def validate_token():
    try:
        current_user = get_jwt_identity()
        print(f"[DEBUG] Validating token for user: {current_user}")
        return jsonify({
            'message': 'Valid token',
            'user': current_user
        }), 200
    except Exception as e:
        print(f"[ERROR] Token validation failed: {str(e)}")
        return jsonify({
            'message': 'Token validation failed',
            'error': str(e)
        }), 401 