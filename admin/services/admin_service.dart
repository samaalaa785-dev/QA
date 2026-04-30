import '../../../core/network/api_client.dart';

class AdminService {
  AdminService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> dashboard() async {
    return await _client.get('/admin/dashboard') as Map<String, dynamic>;
  }

  Future<List<dynamic>> users() async {
    return await _client.get('/admin/users') as List<dynamic>;
  }

  Future<List<dynamic>> workshops() async {
    return await _client.get('/admin/workshops') as List<dynamic>;
  }

  Future<List<dynamic>> bookings() async {
    return await _client.get('/admin/bookings') as List<dynamic>;
  }
}
