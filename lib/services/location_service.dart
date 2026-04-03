import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../utils/token_storage.dart';
import '../utils/place_model.dart'; // PlaceModel 임포트 확인

class LocationService {
  static const String _base = 'http://127.0.0.1:8000';

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. 내 활동 거점 목록 가져오기 (마이페이지 진입 시)
  static Future<ApiResponse<List<PlaceModel>>> getMyLocations() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/api/user/locations'), // 백엔드 엔드포인트 확인 필요
        headers: await _headers(),
      );

      if (res.statusCode == 200) {
        final List<dynamic> body = jsonDecode(res.body);
        // JSON 리스트를 PlaceModel 리st로 변환
        final locations = body.map((e) => PlaceModel.fromJson(e)).toList();
        return ApiResponse.ok(locations);
      }
      return ApiResponse.fail('위치 정보를 불러오지 못했습니다.');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }

  // 2. 활동 거점 업데이트 (수정 페이지에서 저장 시)
  static Future<ApiResponse<void>> updateMyLocations(
    List<PlaceModel> locations,
  ) async {
    try {
      // 서버가 기대하는 필드명으로 변환 (예: location_name, latitude 등)
      final bodyData = locations
          .map(
            (p) => {
              'location_name': p.name,
              'latitude': p.latitude,
              'longitude': p.longitude,
              'is_primary': p.isPrimary,
            },
          )
          .toList();

      final res = await http.put(
        // 또는 patch
        Uri.parse('$_base/api/user/locations'),
        headers: await _headers(),
        body: jsonEncode(bodyData),
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        return ApiResponse.ok(null);
      }

      final errorBody = jsonDecode(res.body);
      return ApiResponse.fail(errorBody['detail'] ?? '위치 정보 수정 실패');
    } catch (e) {
      return ApiResponse.fail('네트워크 오류: $e');
    }
  }
}
