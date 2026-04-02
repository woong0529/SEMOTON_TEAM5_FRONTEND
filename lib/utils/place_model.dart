class PlaceModel {
  String name;
  double latitude;
  double longitude;
  bool isPrimary;

  PlaceModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isPrimary = false,
  });

  // 🌟 이 부분을 추가하세요!
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      // 서버에서 보내주는 키 값(예: 'location_name')에 맞춰서 적어주세요.
      name: json['location_name'] ?? json['name'] ?? '', 
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isPrimary: json['is_primary'] ?? false,
    );
  }

  // (선택사항) 객체를 다시 JSON으로 만들 때 사용
  Map<String, dynamic> toJson() {
    return {
      'location_name': name,
      'latitude': latitude,
      'longitude': longitude,
      'is_primary': isPrimary,
    };
  }
}