import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _isProcedureExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // TODO: 프로젝트 편집
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로젝트 정보 카드
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(label: '구분', value: widget.project.category),
                    InfoRow(label: '분류', value: widget.project.subCategory),
                    InfoRow(label: '상세', value: widget.project.detail),
                    InfoRow(label: '업무내용', value: widget.project.description),
                    InfoRow(label: '담당자', value: widget.project.manager),
                    InfoRow(label: '관리자', value: widget.project.supervisor),
                    InfoRow(label: '상태', value: widget.project.status),
                    InfoRow(label: '시작일', value: _formatDate(widget.project.startDate)),
                  ],
                ),
              ),
            ),
            
            // 업무절차 카드
            SizedBox(height: 16),
            Card(
              child: ExpansionTile(
                title: Text('업무절차', 
                  style: Theme.of(context).textTheme.titleLarge),
                initiallyExpanded: _isProcedureExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isProcedureExpanded = expanded;
                  });
                },
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.project.procedure.split('→').map((step) => 
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_right),
                              SizedBox(width: 8),
                              Expanded(child: Text(step.trim())),
                            ],
                          ),
                        )
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, 
              style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 