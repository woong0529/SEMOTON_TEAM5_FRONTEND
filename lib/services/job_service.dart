import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../utils/token_storage.dart';

class JobService {
  // 에뮬레이터 사용 시 10.0.2.2, 실제 기기 사용 시 서버 IP로 변경 필요
  static const String _base = 'http://localhost:8000';

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // [추가] 시니어 맞춤형 추천 공고 목록 조회
  static Future<ApiResponse<List<Map<String, dynamic>>>> getRecommendedJobs({
    int rangeM = 15000,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/api/search/jobs?range_m=$rangeM'),
        headers: await _headers(),
      );

      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return ApiResponse.ok(list);
      }

      final body = jsonDecode(res.body);
      return ApiResponse.fail(body['detail'] ?? '추천 공고 로드 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // AI 태그 추천 API
  static Future<ApiResponse<Map<String, dynamic>>> getRecommendedTags({
    required String title,
    required String content,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/jobs/recommend-tags'),
        headers: await _headers(),
        body: jsonEncode({'title': title, 'content': content}),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) return ApiResponse.ok(body);
      return ApiResponse.fail(body['detail'] ?? '태그 추천 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 공고 상세 조회
  static Future<ApiResponse<Map<String, dynamic>>> getJobDetail(
    String postId,
  ) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/api/jobs/$postId'),
        headers: await _headers(),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) return ApiResponse.ok(body);
      return ApiResponse.fail(body['detail'] ?? '상세 조회 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 내 공고 목록 조회 (요청자용)
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
      final body = jsonDecode(res.body);
      return ApiResponse.fail(body['detail'] ?? '내 공고 조회 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 공고 등록
  static Future<ApiResponse<Map<String, dynamic>>> createJob({
    required String title,
    required String content,
    required List<String> mainTags,
    required List<String> subTags,
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
          'main_tags': mainTags,
          'sub_tags': subTags,
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
    String postId,
    String status,
  ) async {
    try {
      final res = await http.patch(
        Uri.parse('$_base/api/jobs/$postId'),
        headers: await _headers(),
        body: jsonEncode({'status': status}),
      );
      if (res.statusCode == 200) return ApiResponse.ok(null);

      final body = jsonDecode(res.body);
      return ApiResponse.fail(body['detail'] ?? '상세 상태 변경 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }
}
