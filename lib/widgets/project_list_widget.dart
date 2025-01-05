import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/project_service.dart';
import '../screens/project_detail_screen.dart';

class ProjectListWidget extends StatelessWidget {
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
                      subtitle: Text('${project.category} - ${project.subCategory}'),
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