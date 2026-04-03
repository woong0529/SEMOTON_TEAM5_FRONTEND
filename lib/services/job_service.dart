import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../utils/token_storage.dart';

class JobService {
  static const _base = 'http://10.0.2.2:8000';

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 공고 상세 조회
  static Future<ApiResponse<Map<String, dynamic>>> getJobDetail(
      String postId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/api/jobs/$postId'),
        headers: await _headers(),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) return ApiResponse.ok(body);
      return ApiResponse.fail('상세 조회 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 내 공고 목록 (요청자)
  static Future<ApiResponse<List<Map<String, dynamic>>>> getMyJobs() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/api/jobs/my'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return ApiResponse.ok(list);
      }
      return ApiResponse.fail('내 공고 조회 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 공고 등록
  static Future<ApiResponse<Map<String, dynamic>>> createJob({
    required String title,
    required String content,
    required String categoryTag,
    required String jobDate,
    required String startTime,
    required String locationName,
    required double latitude,
    required double longitude,
    required int reward,
    List<String>? imageUrls,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/jobs'),
        headers: await _headers(),
        body: jsonEncode({
          'title': title,
          'content': content,
          'category_tag': categoryTag,
          'job_date': jobDate,
          'start_time': startTime,
          'latitude': latitude,
          'longitude': longitude,
          'location_name': locationName,
          'reward': reward,
          'image_urls': imageUrls ?? [],
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResponse.ok(body);
      }
      return ApiResponse.fail(body['detail'] ?? '공고 등록 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 공고 상태 변경
  static Future<ApiResponse<void>> updateJobStatus(
      String postId, String status) async {
    try {
      final res = await http.patch(
        Uri.parse('$_base/api/jobs/$postId'),
        headers: await _headers(),
        body: jsonEncode({'status': status}),
      );
      if (res.statusCode == 200) return ApiResponse.ok(null);
      return ApiResponse.fail('상태 변경 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }
}