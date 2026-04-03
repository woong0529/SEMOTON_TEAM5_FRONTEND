import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../utils/token_storage.dart';

class NotificationService {
  static const _base = 'http://172.21.113.16:8000';


  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getNotifications() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/api/matches/notifications'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return ApiResponse.ok(list);
      }
      return ApiResponse.fail('알림 조회 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }
}