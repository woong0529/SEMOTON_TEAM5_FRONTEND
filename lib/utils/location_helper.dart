import 'dart:math';

class LocationHelper {
  /// 두 좌표 간 거리 계산 (Haversine 공식, 단위: km)
  static double distanceKm(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  /// 거리 점수 계산 (추천 알고리즘용)
  static int distanceScore(double km) {
    if (km <= 1.0) return 30;
    if (km <= 3.0) return 20;
    if (km <= 4.0) return 10;
    return 0;
  }

  /// 카카오맵 URL 생성
  static String kakaoMapUrl(double lat, double lng, String name) {
    return 'kakaomap://look?p=$lat,$lng';
  }

  /// 구글맵 URL (카카오맵 없을 때 fallback)
  static String googleMapUrl(double lat, double lng) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  }
}