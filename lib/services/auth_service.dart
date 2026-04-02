import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../utils/token_storage.dart';

class AuthService {
  static const _base = 'http://10.0.2.2:8000';

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await TokenStorage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<ApiResponse<String?>> requestOtp(String phoneNumber) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/auth/otp/request'),
        headers: await _headers(),
        body: jsonEncode({'phone_number': phoneNumber}),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse.ok(body['debug_otp']?.toString());
      }
      return ApiResponse.fail(body['detail'] ?? 'OTP 발송 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> login(
    String phoneNumber,
    String otpCode,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/auth/login'),
        headers: await _headers(),
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp_code': otpCode,
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final token = body['access_token'];
        final isRegistered = body['is_registered'] ?? false;
        final role = body['role'];
        if (token != null &&
            token != 'not_issued' &&
            isRegistered &&
            role != null) {
          await TokenStorage.saveAll(
            token: token,
            role: role,
            userId: '',
          );
        }
        return ApiResponse.ok({
          'access_token': token,
          'is_registered': isRegistered,
          'role': role,
        });
      }
      return ApiResponse.fail(body['detail'] ?? '로그인 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> signupSenior({
    required String phoneNumber,
    required String name,
    required String gender,
    required int birthYear,
    required String authCode,
    List<String>? tags,
    String? bioSummary,
    required List<Map<String, dynamic>> locations,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/auth/signup/senior'),
        headers: await _headers(),
        body: jsonEncode({
          'phone_number': phoneNumber,
          'name': name,
          'gender': gender,
          'birth_year': birthYear,
          'auth_code': authCode,
          'bio_summary': bioSummary ?? '',
          'tags': tags ?? [],
          'profile_icon': 'default_icon',
          'locations': locations,
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        await login(phoneNumber, '123456');
        return ApiResponse.ok(body);
      }
      return ApiResponse.fail(body['detail'] ?? '회원가입 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> signupRequester({
    required String phoneNumber,
    required String nickname,
    required String gender,
    required int birthYear,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/auth/signup/req'),
        headers: await _headers(),
        body: jsonEncode({
          'phone_number': phoneNumber,
          'nickname': nickname,
          'gender': gender,
          'birth_year': birthYear,
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final token = body['access_token'];
        if (token != null) {
          await TokenStorage.saveAll(
            token: token,
            role: 'REQUESTER',
            userId: body['user_id']?.toString() ?? '',
          );
        }
        return ApiResponse.ok(body);
      }
      return ApiResponse.fail(body['detail'] ?? '회원가입 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getMe() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/api/auth/me'),
        headers: await _headers(auth: true),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) return ApiResponse.ok(body);
      return ApiResponse.fail(body['detail'] ?? '조회 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  static Future<ApiResponse<void>> updateMe(
      Map<String, dynamic> fields) async {
    try {
      final res = await http.patch(
        Uri.parse('$_base/api/auth/me'),
        headers: await _headers(auth: true),
        body: jsonEncode(fields),
      );
      if (res.statusCode == 200) return ApiResponse.ok(null);
      final body = jsonDecode(res.body);
      return ApiResponse.fail(body['detail'] ?? '수정 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  static Future<void> logout() async => await TokenStorage.clear();
}