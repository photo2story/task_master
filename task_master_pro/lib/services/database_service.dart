import 'package:postgres/postgres.dart';
import '../config/database_config.dart';
import '../models/project.dart';

class DatabaseService {
  static PostgreSQLConnection? _connection;
  
  Future<PostgreSQLConnection> get connection async {
    if (_connection != null) return _connection!;
    _connection = await _initConnection();
    return _connection!;
  }

  Future<PostgreSQLConnection> _initConnection() async {
    final conn = PostgreSQLConnection(
      DatabaseConfig.host,
      DatabaseConfig.port,
      DatabaseConfig.database,
      username: DatabaseConfig.username,
      password: DatabaseConfig.password
    );
    
    await conn.open();
    return conn;
  }

  // 카테고리 조회
  Future<List<Map<String, dynamic>>> getCategories() async {
    final conn = await connection;
    final results = await conn.query('SELECT * FROM categories');
    return results.map((row) => {
      'id': row[0],
      'name': row[1],
    }).toList();
  }

  // 서브카테고리 조회
  Future<List<Map<String, dynamic>>> getSubcategories(int categoryId) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT * FROM subcategories WHERE category_id = @categoryId',
      substitutionValues: {
        'categoryId': categoryId,
      },
    );
    return results.map((row) => {
      'id': row[0],
      'category_id': row[1],
      'name': row[2],
    }).toList();
  }

  // 직원 목록 조회
  Future<List<Map<String, dynamic>>> getEmployees() async {
    final conn = await connection;
    final results = await conn.query('SELECT * FROM employees');
    return results.map((row) => {
      'id': row[0],
      'name': row[1],
      'position': row[2],
    }).toList();
  }

  // 프로젝트 저장
  Future<void> saveProject({
    required int categoryId,
    required int subcategoryId,
    required String detail,
    required int managerId,
    required int supervisorId,
  }) async {
    final conn = await connection;
    await conn.query(
      '''
      INSERT INTO projects 
        (category_id, subcategory_id, detail, manager_id, supervisor_id)
      VALUES 
        (@categoryId, @subcategoryId, @detail, @managerId, @supervisorId)
      ''',
      substitutionValues: {
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'detail': detail,
        'managerId': managerId,
        'supervisorId': supervisorId,
      },
    );
  }

  Future<int> getCategoryIdByName(String name) async {
    final conn = await connection;
    final result = await conn.query(
      'SELECT id FROM categories WHERE name = @name',
      substitutionValues: {'name': name},
    );
    if (result.isEmpty) throw Exception('Category not found: $name');
    return result.first[0] as int;
  }

  Future<int> getSubcategoryIdByName(String name) async {
    final conn = await connection;
    final result = await conn.query(
      'SELECT id FROM subcategories WHERE name = @name',
      substitutionValues: {'name': name},
    );
    if (result.isEmpty) throw Exception('Subcategory not found: $name');
    return result.first[0] as int;
  }

  Future<int> getEmployeeIdByName(String name) async {
    final conn = await connection;
    final result = await conn.query(
      'SELECT id FROM employees WHERE name = @name',
      substitutionValues: {'name': name},
    );
    if (result.isEmpty) throw Exception('Employee not found: $name');
    return result.first[0] as int;
  }

  Future<void> insertProject(Project project) async {
    try {
      // TODO: 실제 데이터베이스 연동
      print('프로젝트 저장: ${project.name}');
    } catch (e) {
      print('프로젝트 저장 에러: $e');
      rethrow;
    }
  }
} 