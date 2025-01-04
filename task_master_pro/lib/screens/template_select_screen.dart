class TemplateSelectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('업무 템플릿 선택'),
      ),
      body: FutureBuilder<List<TaskTemplate>>(
        future: CsvService().loadTaskTemplates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final templates = snapshot.data ?? [];
          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Card(
                child: ListTile(
                  title: Text('${template.category} > ${template.subCategory} > ${template.detail}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(template.description),
                      if (template.procedure.isNotEmpty)
                        Text('업무절차: ${template.procedure}', 
                          style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  onTap: () {
                    print('\n템플릿 선택됨:');
                    print('카테고리: ${template.category}');
                    print('서브카테고리: ${template.subCategory}');
                    print('상세: ${template.detail}');
                    print('설명: ${template.description}');
                    print('담당자: ${template.manager}');
                    print('관리자: ${template.supervisor}');
                    print('업무절차: ${template.procedure}');

                    if (template.procedure.isEmpty) {
                      print('경고: 업무절차가 비어있습니다!');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('업무절차가 비어있습니다.')),
                      );
                      return;  // 업무절차가 비어있으면 화면 전환하지 않음
                    }

                    final projectCreateScreen = ProjectCreateScreen(
                      initialCategory: template.category,
                      initialSubCategory: template.subCategory,
                      initialDetail: template.detail,
                      initialDescription: template.description,
                      initialManager: template.manager,
                      initialSupervisor: template.supervisor,
                      initialProcedure: template.procedure,
                    );

                    print('\nProjectCreateScreen 생성됨:');
                    print('initialCategory: ${projectCreateScreen.initialCategory}');
                    print('initialSubCategory: ${projectCreateScreen.initialSubCategory}');
                    print('initialDetail: ${projectCreateScreen.initialDetail}');
                    print('initialDescription: ${projectCreateScreen.initialDescription}');
                    print('initialManager: ${projectCreateScreen.initialManager}');
                    print('initialSupervisor: ${projectCreateScreen.initialSupervisor}');
                    print('initialProcedure: ${projectCreateScreen.initialProcedure}');

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => projectCreateScreen),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 