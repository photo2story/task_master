// CSV에서 템플릿을 선택했을 때
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProjectCreateScreen(
      initialCategory: template.category,
      initialSubCategory: template.subCategory,
      initialDetail: template.detail,
      initialDescription: template.description,
      initialManager: template.manager,
      initialSupervisor: template.supervisor,
      initialProcedure: template.procedure,
    ),
  ),
); 