import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/project_service.dart';
import '../screens/project_detail_screen.dart';

class ProjectListWidget extends StatelessWidget {
  Color _getStatusColor(String status) {
    switch (status) {
      case '진행중':
        return Colors.blue;
      case '완료':
        return Colors.green;
      case '보류':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '진행중인 프로젝트',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: Consumer<ProjectService>(
              builder: (context, projectService, child) {
                if (projectService.projects.isEmpty) {
                  return Center(
                    child: Text('프로젝트가 없습니다.\n새 프로젝트를 추가하세요.'),
                  );
                }
                return ListView.builder(
                  itemCount: projectService.projects.length,
                  itemBuilder: (context, index) {
                    final project = projectService.projects[index];
                    return ListTile(
                      title: Text(project.name),
                      subtitle: Text('${project.category} / ${project.subCategory}'),
                      trailing: Chip(
                        label: Text(project.status),
                        backgroundColor: _getStatusColor(project.status),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailScreen(project: project),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 