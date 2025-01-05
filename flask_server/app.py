from flask import Flask, request, jsonify
from datetime import datetime
import pandas as pd
from github_service import GitHubService

app = Flask(__name__)
github_service = GitHubService()
CSV_PATH = 'assets/project_list.csv'

def load_projects():
    """GitHub에서 프로젝트 목록을 가져옴"""
    content, sha = github_service.get_file_content(CSV_PATH)
    if content:
        df = pd.read_csv(pd.StringIO(content))
        return df, sha
    return pd.DataFrame(), None

def save_projects(df, message="Update projects"):
    """GitHub에 프로젝트 목록을 저장"""
    content = df.to_csv(index=False)
    _, sha = github_service.get_file_content(CSV_PATH)
    return github_service.update_file(CSV_PATH, content, message, sha)

@app.route('/api/projects', methods=['GET'])
def get_projects():
    df, _ = load_projects()
    return jsonify(df.to_dict('records'))

@app.route('/api/projects', methods=['POST'])
def add_project():
    project = request.json
    df, _ = load_projects()
    
    df = pd.concat([df, pd.DataFrame([project])], ignore_index=True)
    if save_projects(df, f"Add project: {project['name']}"):
        return jsonify({'success': True})
    return jsonify({'success': False}), 500

@app.route('/api/projects/<project_id>', methods=['PUT'])
def update_project(project_id):
    project = request.json
    df, _ = load_projects()
    
    if project_id in df['id'].values:
        idx = df[df['id'] == project_id].index[0]
        df.loc[idx] = project
        if save_projects(df, f"Update project: {project['name']}"):
            return jsonify({'success': True})
    return jsonify({'success': False}), 404

@app.route('/api/projects/<project_id>', methods=['DELETE'])
def delete_project(project_id):
    df, _ = load_projects()
    
    if project_id in df['id'].values:
        df = df[df['id'] != project_id]
        if save_projects(df, f"Delete project: {project_id}"):
            return jsonify({'success': True})
    return jsonify({'success': False}), 404

if __name__ == '__main__':
    app.run(debug=True)