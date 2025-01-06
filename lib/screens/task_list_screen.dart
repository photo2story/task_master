// 업무 항목을 탭했을 때 호출되는 메서드
void _onTaskTap(TaskTemplate template) async {
  try {
    final now = DateTime.now();
    
    // 새 프로젝트 생성
    final project = Project(
      id: const Uuid().v4(),
      name: '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
           '${template.category}_${template.subCategory}_${template.detail}',
      category: template.category,
      subCategory: template.subCategory,
      description: template.description,
      detail: template.detail,
      procedure: template.procedure,
      startDate: now,
      endDate: now,
      status: '진행중',
      manager: template.manager,
      supervisor: template.supervisor,
      createdAt: now,
      updatedAt: now,
      updateNotes: '프로젝트 생성',
    );

    // 프로젝트 생성 및 저장
    await context.read<ProjectService>().createProject(project);

    if (mounted) {
      // 바로 ProjectDetailScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectDetailScreen(
            project: project,
            isNewProject: true,
          ),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로젝트 생성 실패: $e')),
      );
    }
  }
} 