import os
import base64
import requests
from dotenv import load_dotenv

load_dotenv()

class GitHubService:
    def __init__(self):
        self.token = os.getenv('GITHUB_TOKEN')
        self.repo = 'photo2story/task_master'
        self.branch = 'main'
        self.base_url = 'https://api.github.com'

    def get_file_content(self, path):
        """GitHub에서 파일 내용과 SHA를 가져옴"""
        url = f"{self.base_url}/repos/{self.repo}/contents/{path}"
        headers = {
            'Authorization': f'token {self.token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            content = response.json()
            file_content = base64.b64decode(content['content']).decode('utf-8')
            return file_content, content['sha']
        return None, None

    def update_file(self, path, content, message, sha=None):
        """GitHub의 파일을 업데이트하거나 생성"""
        url = f"{self.base_url}/repos/{self.repo}/contents/{path}"
        headers = {
            'Authorization': f'token {self.token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        data = {
            'message': message,
            'content': base64.b64encode(content.encode()).decode(),
            'branch': self.branch
        }
        
        if sha:
            data['sha'] = sha
            
        response = requests.put(url, json=data, headers=headers)
        return response.status_code in [200, 201] 