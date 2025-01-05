from flask import Flask, request, jsonify
import pandas as pd
from datetime import datetime
import uuid

app = Flask(__name__)

CSV_FILE = 'projects.csv'

def load_projects():
    try:
        df = pd.read_csv(CSV_FILE)
        df['start_date'] = pd.to_datetime(df['start_date'])
        return df
    except FileNotFoundError:
        return pd.DataFrame(columns=[
            'id', 'name', 'category', 'subcategory', 'description', 
            'detail', 'procedure', 'start_date', 'status', 
            'manager', 'supervisor', 'created_at', 'updated_at', 'update_notes'
        ])

def save_projects(df):
    df.to_csv(CSV_FILE, index=False)

@app.route('/api/projects', methods=['GET'])
def get_projects():
    df = load_projects()
    return jsonify(df.to_dict('records'))

@app.route('/api/projects', methods=['POST'])
def add_project():
    project = request.json
    df = load_projects()
    
    project['id'] = str(uuid.uuid4())
    project['created_at'] = datetime.now().isoformat()
    project['updated_at'] = project['created_at']
    
    df = pd.concat([df, pd.DataFrame([project])], ignore_index=True)
    save_projects(df)
    
    return jsonify({'success': True})

@app.route('/api/projects/<project_id>', methods=['PUT'])
def update_project(project_id):
    project = request.json
    df = load_projects()
    
    if project_id in df['id'].values:
        idx = df[df['id'] == project_id].index[0]
        project['updated_at'] = datetime.now().isoformat()
        df.loc[idx] = project
        save_projects(df)
        return jsonify({'success': True})
    
    return jsonify({'success': False}), 404

@app.route('/api/projects/<project_id>', methods=['DELETE'])
def delete_project(project_id):
    df = load_projects()
    
    if project_id in df['id'].values:
        df = df[df['id'] != project_id]
        save_projects(df)
        return jsonify({'success': True})
    
    return jsonify({'success': False}), 404

if __name__ == '__main__':
    app.run(debug=True)