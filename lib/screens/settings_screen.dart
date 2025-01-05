class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final csvService = context.read<CsvService>();
    
    return Scaffold(
      appBar: AppBar(title: Text('설정')),
      body: ListView(
        children: [
          ListTile(
            title: Text('저장 위치'),
            subtitle: Text(csvService.getStorageLocation()),
          ),
          ListTile(
            title: Text('파일 확인'),
            onTap: () async {
              final exists = await csvService.projectFileExists();
              final content = await csvService.readProjectFile();
              
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('프로젝트 파일 정보'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('파일 존재: ${exists ? "예" : "아니오"}'),
                        if (content != null) ...[
                          SizedBox(height: 16),
                          Text('파일 내용:'),
                          Text(content),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('확인'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 