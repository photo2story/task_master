from flask import Blueprint, request, jsonify
from app.models.user import User
from app import db, bcrypt, jwt
from flask_jwt_extended import create_access_token
from datetime import datetime
from flask_jwt_extended import jwt_required

auth = Blueprint('auth', __name__)

@auth.route('/register', methods=['POST'])
def register():
    try:
        data = request.get_json()

        # 필수 필드 검증
        required_fields = ['email', 'password', 'name', 'role', 'department']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'message': f'{field} 필드가 필요합니다.'
                }), 400

        # 이메일 중복 체크
        if User.query.filter_by(email=data['email']).first():
            return jsonify({
                'message': '이미 등록된 이메일입니다.'
            }), 400

        # 비밀번호 해싱
        password_hash = bcrypt.generate_password_hash(data['password']).decode('utf-8')

        # 새 사용자 생성
        new_user = User(
            email=data['email'],
            password_hash=password_hash,
            name=data['name'],
            role=data['role'],
            department=data['department']
        )

        db.session.add(new_user)
        db.session.commit()

        return jsonify({
            'message': '회원가입이 완료되었습니다.',
            'user': {
                'id': str(new_user.id),
                'email': new_user.email,
                'name': new_user.name,
                'role': new_user.role,
                'department': new_user.department
            }
        }), 201

    except Exception as e:
        print(f"회원가입 오류: {str(e)}")  # 서버 콘솔에 오류 출력
        db.session.rollback()
        return jsonify({
            'message': f'회원가입 처리 중 오류가 발생했습니다: {str(e)}'
        }), 500

@auth.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        if not data or 'email' not in data or 'password' not in data:
            return jsonify({
                'message': '이메일과 비밀번호를 입력해주세요.'
            }), 400

        user = User.query.filter_by(email=data['email']).first()

        if not user or not bcrypt.check_password_hash(user.password_hash, data['password']):
            return jsonify({
                'message': '이메일 또는 비밀번호가 잘못되었습니다.'
            }), 401

        # 마지막 로그인 시간 업데이트
        user.last_login_at = datetime.utcnow()
        db.session.commit()

        # JWT 토큰 생성
        access_token = create_access_token(identity=str(user.id))

        return jsonify({
            'message': '로그인 성공',
            'token': access_token,
            'user': {
                'id': str(user.id),
                'email': user.email,
                'name': user.name,
                'role': user.role,
                'department': user.department
            }
        }), 200

    except Exception as e:
        print(f"로그인 오류: {str(e)}")  # 서버 콘솔에 오류 출력
        return jsonify({
            'message': f'로그인 처리 중 오류가 발생했습니다: {str(e)}'
        }), 500

@auth.route('/reset', methods=['POST'])
def reset_database():
    try:
        # 모든 사용자 삭제
        db.session.query(User).delete()
        db.session.commit()
        return jsonify({'message': '데이터베이스가 초기화되었습니다.'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': str(e)}), 500 

@auth.route('/validate', methods=['GET'])
@jwt_required()
def validate_token():
    return jsonify({'message': 'Valid token'}), 200 