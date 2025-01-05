import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 600;

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
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskTemplateScreen()),
            ),
            tooltip: '새 프로젝트',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: isNarrowScreen
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCurrentMonthProjects(),
                _buildUpcomingProjects(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: _buildCurrentMonthProjects(),
                ),
                Expanded(
                  child: _buildUpcomingProjects(),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildCurrentMonthProjects() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              '이번 달 프로젝트',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Consumer<ProjectService>(
            builder: (context, projectService, _) {
              final currentMonthProjects = projectService.projects
                  .where((p) =>
                    p.startDate.year == DateTime.now().year &&
                    p.startDate.month == DateTime.now().month
                  )
                  .toList()
                  ..sort((a, b) {
                    if (a.status == '완료' && b.status != '완료') return 1;
                    if (a.status != '완료' && b.status == '완료') return -1;
                    return a.startDate.compareTo(b.startDate);
                  });

              return currentMonthProjects.isEmpty
                  ? Center(child: Text('이번 달 프로젝트가 없습니다'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: currentMonthProjects.length,
                      itemBuilder: (context, index) {
                        final project = currentMonthProjects[index];
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          minLeadingWidth: 0,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          title: Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: project.name.substring(0, 8),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: project.status == '완료'
                                              ? Color(0xFFFFE5B4).withOpacity(0.5)
                                              : Color(0xFFFFE5B4),
                                        ),
                                      ),
                                      TextSpan(
                                        text: project.name.substring(8),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: project.status == '완료'
                                              ? (Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.grey[600]
                                                  : Colors.grey[400])
                                              : (Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.grey[300]
                                                  : Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                width: 48,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(project.status),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  project.status,
                                  style: TextStyle(fontSize: 11),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            project.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: project.status == '완료'
                                  ? Color(0xFFFFB5B5).withOpacity(0.5)
                                  : Color(0xFFFFB5B5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _showProjectDetails(project),
                        );
                      },
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingProjects() {
    final projects = context.watch<ProjectService>().projects;
    final currentMonthProjects = projects
        .where((p) => 
          p.startDate.year == _focusedDay.year && 
          p.startDate.month == _focusedDay.month
        )
        .toList()
        ..sort((a, b) {
          if (a.status == '완료' && b.status != '완료') return 1;
          if (a.status != '완료' && b.status == '완료') return -1;
          return a.startDate.compareTo(b.startDate);
        });
    
    Map<String, int> categoryStats = {};
    for (var project in currentMonthProjects) {
      categoryStats[project.category] = (categoryStats[project.category] ?? 0) + 1;
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              '다음 프로젝트',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            height: 220,
            child: Card(
              margin: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: ProjectPieChart(categoryStats: categoryStats),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime(DateTime.now().year + 1, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        eventLoader: (day) {
                          return projects.where((p) => isSameDay(p.startDate, day)).toList();
                        },
                        availableGestures: AvailableGestures.none,
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white70 
                                : Colors.black87,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.red[200] 
                                : Colors.red,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(fontSize: 12),
                          leftChevronIcon: Icon(Icons.chevron_left, size: 14),
                          rightChevronIcon: Icon(Icons.chevron_right, size: 14),
                          headerPadding: EdgeInsets.symmetric(vertical: 4),
                          headerMargin: EdgeInsets.only(bottom: 4),
                        ),
                        daysOfWeekHeight: 20, // 요일 행 높이 증가
                        rowHeight: 18,     // 날짜 행 높이 증가
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          cellMargin: EdgeInsets.all(1),
                          cellPadding: EdgeInsets.zero,
                          defaultTextStyle: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[400]  // 밝은 회색
                                : Colors.black87,
                          ),
                          weekendTextStyle: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.red[200]  // 주말은 빨간색 유지
                                : Colors.red,
                          ),
                          selectedTextStyle: TextStyle(
                            fontSize: 11,
                            color: Colors.white,  // 선택된 날짜는 흰색 유지
                            fontWeight: FontWeight.bold,
                          ),
                          todayTextStyle: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[300]  // 오늘 날짜는 조금 더 밝은 회색
                                : Colors.black87,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, date, _) {
                            final events = projects.where((p) => isSameDay(p.startDate, date)).toList();
                            return Container(
                              margin: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: events.isNotEmpty 
                                    ? (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.blue[900]  // 다크모드에서는 진한 파란색
                                        : Colors.blue[100])
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.grey[400]
                                        : Colors.black87,
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
                                color: events.isNotEmpty
                                    ? (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.blue[800]  // 이벤트가 있는 선택된 날짜
                                        : Colors.blue[200])
                                    : (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey[800]  // 이벤트가 없는 선택된 날짜
                                        : Colors.blue[50]),
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white  // 선택된 날짜는 흰색으로 변경
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: currentMonthProjects.length,
              itemBuilder: (context, index) {
                final project = currentMonthProjects[index];
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  minLeadingWidth: 0,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  title: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: project.name.substring(0, 8),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: project.status == '완료'
                                      ? Color(0xFFFFE5B4).withOpacity(0.5)
                                      : Color(0xFFFFE5B4),
                                ),
                              ),
                              TextSpan(
                                text: project.name.substring(8),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: project.status == '완료'
                                      ? (Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[600]
                                          : Colors.grey[400])
                                      : (Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[300]
                                          : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        width: 48,
                        decoration: BoxDecoration(
                          color: _getStatusColor(project.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          project.status,
                          style: TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    project.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: project.status == '완료'
                          ? Color(0xFFFFB5B5).withOpacity(0.5)
                          : Color(0xFFFFB5B5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _showProjectDetails(project),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '진행중':
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.blue[900]!  // 다크모드에서는 진한 파란색
            : Colors.blue[100]!;
      case '완료':
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.green[900]!  // 다크모드에서는 진한 초록색
            : Colors.green[100]!;
      case '지연':
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.red[900]!  // 다크모드에서는 진한 빨간색
            : Colors.red[100]!;
      default:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]!  // 다크모드에서는 진한 회색
            : Colors.grey[100]!;
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