import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/api_response.dart';
import '../utils/token_storage.dart';

class AuthService {
  static String get _base => dotenv.env['BASE_URL'] ?? 'http://172.21.113.16:8000';

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
      print('📡 OTP 요청: $_base/api/auth/otp/request');
      final res = await http.post(
        Uri.parse('$_base/api/auth/otp/request'),
        headers: await _headers(),
        body: jsonEncode({'phone_number': phoneNumber}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('❌ OTP 타임아웃');
          throw Exception('OTP 요청 타임아웃');
        },
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        print('✅ OTP 발송 성공');
        return ApiResponse.ok(body['debug_otp']?.toString());
      }
      print('❌ OTP 오류: ${body['detail']}');
      return ApiResponse.fail(body['detail'] ?? 'OTP 발송 실패');
    } catch (e) {
      print('❌ OTP 네트워크 오류: $e');
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> login(
    String phoneNumber,
    String otpCode,
  ) async {
    try {
      print('📡 로그인 요청: $_base/api/auth/login');
      final res = await http.post(
        Uri.parse('$_base/api/auth/login'),
        headers: await _headers(),
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp_code': otpCode,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('❌ 로그인 타임아웃');
          throw Exception('로그인 요청 타임아웃');
        },
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        print('✅ 로그인 성공');
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
      print('❌ 로그인 실패: ${body['detail']}');
      return ApiResponse.fail(body['detail'] ?? '로그인 실패');
    } catch (e) {
      print('❌ 로그인 네트워크 오류: $e');
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
      print('📡 시니어 회원가입 요청: $_base/api/auth/signup/senior');
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
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('❌ 시니어 회원가입 타임아웃');
          throw Exception('서버 응답 시간 초과');
        },
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        print('✅ 시니어 회원가입 성공');
        await login(phoneNumber, '123456');
        return ApiResponse.ok(body);
      }
      print('❌ 시니어 회원가입 실패: ${body['detail']}');
      return ApiResponse.fail(body['detail'] ?? '회원가입 실패');
    } catch (e) {
      print('❌ 시니어 회원가입 네트워크 오류: $e');
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
      print('📡 회원가입 요청 시작');
      print('🌐 BASE_URL: $_base');
      print('📝 요청 데이터: phone=$phoneNumber, nickname=$nickname, gender=$gender, birth=$birthYear');
      
      final res = await http.post(
        Uri.parse('$_base/api/auth/signup/req'),
        headers: await _headers(),
        body: jsonEncode({
          'phone_number': phoneNumber,
          'nickname': nickname,
          'gender': gender,
          'birth_year': birthYear,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('❌ 타임아웃: 서버 응답 없음 (10초)');
          throw Exception('서버 응답 시간 초과');
        },
      );
      
      print('✅ 응답 받음: 상태코드=${res.statusCode}');
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        print('✨ 회원가입 성공');
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
      print('❌ 서버 오류: ${body['detail']}');
      return ApiResponse.fail(body['detail'] ?? '회원가입 실패');
    } catch (e) {
      print('❌ 네트워크 오류: $e');
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