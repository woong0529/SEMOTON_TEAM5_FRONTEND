import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/tag_chip.dart';
import 'job_detail_screen.dart';

class SearchPage extends StatefulWidget {
  final bool isSenior;
  const SearchPage({super.key, required this.isSenior});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLocation;
  List<Map<String, dynamic>> _results = [];
  bool _searched = false;

  final List<String> _categories = [
    '#병원동행', '#말벗', '#강아지산책', '#장보기대행',
    '#아이돌봄', '#청소', '#관공서동행', '#집밥제조',
  ];

  final List<String> _locations = [
    '전체', '동대문구', '성북구', '중랑구', '광진구', '노원구',
  ];

  final List<Map<String, dynamic>> _allJobs = [
    {
      'post_id': 'post-001',
      'title': '병원 동행 도와주세요',
      'content': '접수와 진료 동행을 부탁드려요.',
      'job_date': '2026-03-30',
      'start_time': '10:00',
      'location_name': '동대문구 회기역 근처',
      'reward': 25000,
      'requesterName': '김민지',
      'requesterGender': '여성',
      'phone': '010-2222-3333',
      'category_tag': '#병원동행',
      'tags': ['#병원동행', '#말벗'],
      'district': '동대문구',
    },
    {
      'post_id': 'post-002',
      'title': '강아지 산책 부탁드려요',
      'content': '30분 단지 산책을 부탁드립니다.',
      'job_date': '2026-03-31',
      'start_time': '16:00',
      'location_name': '성북구 휘경동',
      'reward': 15000,
      'requesterName': '박소연',
      'requesterGender': '여성',
      'phone': '010-4444-5555',
      'category_tag': '#강아지산책',
      'tags': ['#강아지산책', '#말벗'],
      'district': '성북구',
    },
    {
      'post_id': 'post-003',
      'title': '장보기와 반찬 정리 도와주세요',
      'content': '마트 장보기 + 냉장고 정리를 부탁드려요.',
      'job_date': '2026-04-01',
      'start_time': '14:00',
      'location_name': '동대문구 이문동',
      'reward': 20000,
      'requesterName': '이수정',
      'requesterGender': '여성',
      'phone': '010-8888-9999',
      'category_tag': '#장보기대행',
      'tags': ['#장보기대행', '#청소'],
      'district': '동대문구',
    },
    {
      'post_id': 'post-004',
      'title': '아이 학습 도우미 구합니다',
      'content': '초등학생 숙제 도우미를 부탁드려요.',
      'job_date': '2026-04-02',
      'start_time': '15:00',
      'location_name': '노원구 자택',
      'reward': 30000,
      'requesterName': '최지영',
      'requesterGender': '여성',
      'phone': '010-1111-2222',
      'category_tag': '#아이돌봄',
      'tags': ['#아이돌봄', '#말벗'],
      'district': '노원구',
    },
  ];

  void _search() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _results = _allJobs.where((job) {
        final titleMatch = query.isEmpty ||
            (job['title'] as String).toLowerCase().contains(query);
        final categoryMatch = _selectedCategory == null ||
            ((job['tags'] as List?)?.cast<String>() ?? [])
                .contains(_selectedCategory);
        final locationMatch = _selectedLocation == null ||
            _selectedLocation == '전체' ||
            (job['district'] as String?) == _selectedLocation;
        return titleMatch && categoryMatch && locationMatch;
      }).toList();
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('공고 검색',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),

        // 검색바
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '공고 제목 검색',
            prefixIcon:
                const Icon(Icons.search, color: AppColors.subText),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _search(),
        ),

        const SizedBox(height: 20),

        // 카테고리 필터
        const Text('카테고리',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final sel = _selectedCategory == cat;
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedCategory = sel ? null : cat),
              child: TagChip(label: cat, highlighted: sel),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 지역 필터
        const Text('활동 지역',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _locations.map((loc) {
              final sel = _selectedLocation == loc;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(
                      () => _selectedLocation = sel ? null : loc),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel
                              ? AppColors.primary
                              : AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place_outlined,
                            size: 14,
                            color: sel
                                ? Colors.white
                                : AppColors.subText),
                        const SizedBox(width: 4),
                        Text(loc,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  sel ? Colors.white : AppColors.text,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // 검색 버튼
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _search,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('검색하기',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),

        const SizedBox(height: 28),

        // 결과
        if (_searched) ...[
          Text('검색 결과 ${_results.length}건',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.subText)),
          const SizedBox(height: 14),
          if (_results.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text('검색 결과가 없어요',
                    style: TextStyle(color: AppColors.subText)),
              ),
            )
          else
            ..._results.map((job) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailScreen(
                            post: job, isSenior: widget.isSenior),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 14,
                              offset: Offset(0, 6)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(job['title'] as String,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  job['category_tag'] as String,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined,
                                  size: 14,
                                  color: AppColors.subText),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                    job['location_name'] as String,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.subText)),
                              ),
                              Text('${job['reward']}원',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
        ],
      ],
    );
  }
}