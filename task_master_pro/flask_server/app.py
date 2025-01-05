from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv

# .env 파일 경로 지정 (상위 디렉토리의 .env 파일)
dotenv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
load_dotenv(dotenv_path)

app = Flask(__name__)
CORS(app)  # CORS 활성화

# 데이터베이스 연결 설정
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT'),
        database=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD')
    )

# 테이블 생성
def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # 테이블이 없을 때만 생성
        cur.execute('''
            CREATE TABLE IF NOT EXISTS projects (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                category TEXT NOT NULL,
                subcategory TEXT NOT NULL,
                detail TEXT,
                description TEXT,
                manager TEXT,
                supervisor TEXT,
                procedure TEXT,
                start_date TIMESTAMP,
                status TEXT,
                created_at TIMESTAMP,
                updated_at TIMESTAMP
            )
        ''')
        conn.commit()
        print("테이블 확인 완료")
    except Exception as e:
        print(f"테이블 생성 에러: {e}")
        conn.rollback()
    finally:
        cur.close()
        conn.close()

@app.route('/api/projects', methods=['POST'])
def create_project():
    try:
        data = request.get_json()
        print("받은 데이터:", data)
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute('''
            INSERT INTO projects (
                id, name, category, subcategory, detail, description,
                manager, supervisor, procedure, start_date, status,
                created_at, updated_at
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            )
        ''', (
            data['id'],
            data['name'],
            data['category'],
            data['subcategory'],
            data['detail'],
            data['description'],
            data['manager'],
            data['supervisor'],
            data['procedure'],
            data['startDate'],
            data['status'],
            data['createdAt'],
            data['updatedAt']
        ))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({'message': '프로젝트가 생성되었습니다'}), 201
        
    except Exception as e:
        print(f"에러 발생: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/projects', methods=['GET'])
def get_projects():
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        cur.execute('SELECT * FROM projects ORDER BY created_at DESC')
        projects = cur.fetchall()
        
        # ISO 8601 형식으로 날짜 변환
        for project in projects:
            project['start_date'] = project['start_date'].isoformat() if project['start_date'] else None
            project['created_at'] = project['created_at'].isoformat() if project['created_at'] else None
            project['updated_at'] = project['updated_at'].isoformat() if project['updated_at'] else None
        
        cur.close()
        conn.close()
        
        return jsonify(projects), 200
        
    except Exception as e:
        print(f"에러 발생: {e}")
        return jsonify({'error': str(e)}), 500

# 프로젝트 수정
@app.route('/api/projects/<string:project_id>', methods=['PUT'])
def update_project(project_id):
    try:
        data = request.get_json()
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute('''
            UPDATE projects 
            SET name = %s, category = %s, subcategory = %s, 
                detail = %s, description = %s, manager = %s,
                supervisor = %s, procedure = %s, start_date = %s,
                status = %s, updated_at = %s
            WHERE id = %s
        ''', (
            data['name'],
            data['category'],
            data['subcategory'],
            data['detail'],
            data['description'],
            data['manager'],
            data['supervisor'],
            data['procedure'],
            data['startDate'],
            data['status'],
            datetime.now(),
            project_id
        ))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({'message': '프로젝트가 수정되었습니다'}), 200
        
    except Exception as e:
        print(f"에러 발생: {e}")
        return jsonify({'error': str(e)}), 500

# 프로젝트 삭제
@app.route('/api/projects/<string:project_id>', methods=['DELETE'])
def delete_project(project_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute('DELETE FROM projects WHERE id = %s', (project_id,))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({'message': '프로젝트가 삭제되었습니다'}), 200
        
    except Exception as e:
        print(f"에러 발생: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    init_db()  # 서버 시작 시 테이블 생성
    app.run(host='0.0.0.0', port=5000, debug=True)
    
    
# cd flask_server
# python -m venv .venv
# .venv\Scripts\activate

# source .venv/bin/activate 
  
# python -m pip install --upgrade pip     
# pip install -r requirements.txt

# python app.py