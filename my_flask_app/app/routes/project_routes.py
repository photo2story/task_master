from flask import Blueprint, current_app, jsonify, send_file, request
from flask_jwt_extended import jwt_required
import os
import datetime
import traceback

project_bp = Blueprint('project', __name__)

@project_bp.route('/csv', methods=['GET'])
@jwt_required()
def get_csv():
    try:
        print("\n[DEBUG] ===== CSV File Request =====")
        print("[DEBUG] Request received at:", datetime.datetime.now())
        print("[DEBUG] Request headers:", request.headers)
        
        # CSV 파일 경로 (static 폴더 기준)
        csv_path = os.path.join(current_app.root_path, '..', 'static', 'task_list.csv')
        print(f"[DEBUG] Looking for CSV file at: {csv_path}")
        print(f"[DEBUG] File exists: {os.path.exists(csv_path)}")
        
        if not os.path.exists(csv_path):
            print(f"[ERROR] CSV file not found at {csv_path}")
            return jsonify({'message': 'CSV file not found'}), 404

        # 파일 크기 확인
        file_size = os.path.getsize(csv_path)
        print(f"[DEBUG] CSV file size: {file_size} bytes")

        # 파일 내용 미리보기
        with open(csv_path, 'r', encoding='utf-8') as f:
            preview = f.read(200)
            print(f"[DEBUG] File preview: {preview}")

        # send_file을 사용하여 파일 직접 전송
        response = send_file(
            csv_path,
            mimetype='text/csv',
            as_attachment=True,
            download_name='task_list.csv'
        )
        
        print("[DEBUG] Response headers:", response.headers)
        print("[DEBUG] ===== CSV File Request Completed =====\n")
        return response

    except Exception as e:
        print(f"[ERROR] ===== CSV File Request Failed =====")
        print(f"[ERROR] Error type: {type(e).__name__}")
        print(f"[ERROR] Error message: {str(e)}")
        print(f"[ERROR] Stack trace:", traceback.format_exc())
        current_app.logger.error(f"Error serving CSV file: {e}")
        return jsonify({'message': f'Failed to load CSV file: {str(e)}'}), 500