import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../utils/token_storage.dart';

class MatchingService {
  static const _base = 'http://10.0.2.2:8000';

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 시니어 지원
  static Future<ApiResponse<String>> applyJob(String postId) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/matches/apply'),
        headers: await _headers(),
        body: jsonEncode({'post_id': postId}),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResponse.ok(body['match_id']?.toString() ?? '');
      }
      return ApiResponse.fail(body['detail'] ?? '지원 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 요청자 직접 제안
  static Future<ApiResponse<String>> proposeMatch({
    required String postId,
    required String seniorId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/matches/propose'),
        headers: await _headers(),
        body: jsonEncode({'post_id': postId, 'senior_id': seniorId}),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResponse.ok(body['match_id']?.toString() ?? '');
      }
      return ApiResponse.fail(body['detail'] ?? '제안 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 수락 / 거절
  static Future<ApiResponse<void>> updateMatchStatus(
      String matchId, String status) async {
    try {
      final res = await http.patch(
        Uri.parse('$_base/api/matches/$matchId/status'),
        headers: await _headers(),
        body: jsonEncode({'status': status}),
      );
      if (res.statusCode == 200) return ApiResponse.ok(null);
      final body = jsonDecode(res.body);
      return ApiResponse.fail(body['detail'] ?? '상태 변경 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 활성 매칭 조회
  static Future<ApiResponse<List<Map<String, dynamic>>>> getActiveMatches() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/api/matches/active'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return ApiResponse.ok(list);
      }
      return ApiResponse.fail('매칭 조회 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 일 종료
  static Future<ApiResponse<void>> completeJob(String matchId) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/matches/$matchId/complete'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) return ApiResponse.ok(null);
      final body = jsonDecode(res.body);
      return ApiResponse.fail(body['detail'] ?? '종료 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }
}