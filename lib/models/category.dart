class JobCategory {
  final String main;
  final String sub;

  const JobCategory({required this.main, required this.sub});
}

class AppCategories {
  static const Map<String, List<String>> categories = {
    '가사 및 환경 관리': ['청소', '빨래', '정리정돈', '장보기대행', '집밥제조'],
    '동행 및 돌봄': ['병원동행', '말벗', '관공서동행', '어르신돌봄'],
    '반려동물': ['강아지산책', '반려동물케어'],
    '아동 교육': ['놀이학습', '학습보조', '아이돌봄'],
    '기타 생활지원': ['심부름', '이사보조', '차량동행'],
  };

  static List<String> get allMains => categories.keys.toList();

  static List<String> subsOf(String main) =>
      categories[main] ?? [];

  /// 태그 문자열로 main 카테고리 찾기
  static String? mainFromSub(String sub) {
    for (final entry in categories.entries) {
      if (entry.value.contains(sub)) return entry.key;
    }
    return null;
  }
}