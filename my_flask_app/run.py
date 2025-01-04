from app import create_app

app = create_app()

if __name__ == '__main__':
    app.run(debug=True) 
    

"""
# 프로젝트 디렉토리로 이동
cd my_flask_app

# 가상환경 활성화
.\.venv\Scripts\activate
python run.py

# 서버 실행
python run.py
"""