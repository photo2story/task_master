import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/project_service.dart';
import '../models/project.dart';
import 'project_create_screen.dart';
import 'task_template_screen.dart';
import 'project_detail_screen.dart';
import '../widgets/project_pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _focusedDay = DateTime.now().add(Duration(days: 32));
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      await context.read<ProjectService>().loadProjects();
    } catch (e) {
      print('프로젝트 로드 에러: $e');
      // 에러 처리 (예: 스낵바 표시)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로젝트 로드 중 오류가 발생했습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Master'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProjects,
            tooltip: '새로고침',
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskTemplateScreen()),
            ),
            tooltip: '업무 목록',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskTemplateScreen()),
        ),
        child: Icon(Icons.add),
        tooltip: '새 프로젝트',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Row(
        children: [
          // 왼쪽: 이번 달 프로젝트
          Expanded(
            flex: 1,
            child: _buildCurrentMonthProjects(),
          ),
          // 오른쪽: 다음 프로젝트들
          Expanded(
            flex: 1,
            child: _buildUpcomingProjects(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMonthProjects() {
    final projects = context.watch<ProjectService>().projects;
    final currentMonthProjects = projects.where((p) => 
      p.startDate.year == DateTime.now().year && 
      p.startDate.month == DateTime.now().month
    ).toList();

    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '이번 달 프로젝트',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProjects,
              child: currentMonthProjects.isEmpty
                  ? Center(child: Text('이번 달 프로젝트가 없습니다.'))
                  : ListView.builder(
                      itemCount: currentMonthProjects.length,
                      itemBuilder: (context, index) {
                        final project = currentMonthProjects[index];
                        return ListTile(
                          title: Text(project.name),
                          subtitle: Text(project.description),
                          trailing: Chip(
                            label: Text(project.status),
                            backgroundColor: _getStatusColor(project.status),
                          ),
                          onTap: () => _showProjectDetails(project),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingProjects() {
    final projects = context.watch<ProjectService>().projects;
    
    // 현재 표시된 월의 프로젝트 필터링
    final currentMonthProjects = projects.where((p) => 
      p.startDate.year == _focusedDay.year && 
      p.startDate.month == _focusedDay.month
    ).toList();
    
    // 카테고리별 통계 계산
    Map<String, int> categoryStats = {};
    for (var project in currentMonthProjects) {
      categoryStats[project.category] = (categoryStats[project.category] ?? 0) + 1;
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '다음 프로젝트',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // 상단 영역
          Container(
            padding: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 파이 차트
                SizedBox(
                  width: 140,
                  child: ProjectPieChart(categoryStats: categoryStats),
                ),
                // 오른쪽: 달력
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 160,
                      child: TableCalendar(
                        firstDay: DateTime.now().add(Duration(days: 1)),
                        lastDay: DateTime(DateTime.now().year, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                          _loadProjects();
                        },
                        eventLoader: (day) {
                          return projects.where((p) => isSameDay(p.startDate, day)).toList();
                        },
                        availableGestures: AvailableGestures.none,
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          cellMargin: EdgeInsets.zero,
                          cellPadding: EdgeInsets.all(1),
                          defaultTextStyle: TextStyle(fontSize: 11),
                          weekendTextStyle: TextStyle(fontSize: 11),
                          selectedTextStyle: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          todayTextStyle: TextStyle(fontSize: 11),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, date, _) {
                            final events = projects.where((p) => isSameDay(p.startDate, date)).toList();
                            return Container(
                              margin: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: events.isNotEmpty ? Colors.blue[100] : null,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                          selectedBuilder: (context, date, _) {
                            final events = projects.where((p) => isSameDay(p.startDate, date)).toList();
                            return Container(
                              margin: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: events.isNotEmpty ? Colors.blue[200] : Colors.blue[50],
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(fontSize: 12),
                          leftChevronIcon: Icon(Icons.chevron_left, size: 14),
                          rightChevronIcon: Icon(Icons.chevron_right, size: 14),
                          headerPadding: EdgeInsets.symmetric(vertical: 2),
                        ),
                        daysOfWeekHeight: 16,
                        rowHeight: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 하단 영역: 프로젝트 목록
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProjects,
              child: ListView.builder(
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: currentMonthProjects.length,
                itemBuilder: (context, index) {
                  final project = currentMonthProjects[index];
                  return ListTile(
                    title: Text(project.name, style: TextStyle(fontSize: 14)),
                    subtitle: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12),
                        SizedBox(width: 4),
                        Text(
                          '${project.startDate.month}/${project.startDate.day}',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            project.detail,
                            style: TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(project.status),
                      backgroundColor: _getStatusColor(project.status),
                    ),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    onTap: () => _showProjectDetails(project),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '진행중':
        return Colors.blue[100]!;
      case '완료':
        return Colors.green[100]!;
      case '지연':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  void _showProjectDetails(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );
  }
} 