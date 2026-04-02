import 'package:flutter/material.dart';

// 1. 데이터 모델 정의 (백엔드 스키마 대응)
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
}

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  // 선택된 장소들을 담을 리스트 (최대 3개)
  final List<PlaceModel> _selectedPlaces = [];

  // 현재 지도에서 임시로 찍힌 좌표 (카카오맵 API 연동 시 업데이트될 변수)
  final double _currentLat = 37.5665;
  final double _currentLng = 126.9780;
  final String _currentMapName = "선택된 위치 명칭"; // API에서 받아올 장소명

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자주 가는 장소 설정'),
        actions: [
          // 모든 설정 완료 후 이전 페이지로 데이터 전달
          TextButton(
            onPressed: _selectedPlaces.isNotEmpty ? _finishSelection : null,
            child: const Text(
              "완료",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // [상단] 카카오맵 영역
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Stack(
                children: [
                  const Center(
                    child: Text("카카오맵 API 위젯 위치\n(지도를 터치해 장소를 선택하세요)"),
                  ),
                  // 중앙 핀 표시
                  const Center(
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                  // 장소 추가 버튼
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton.extended(
                      onPressed: _selectedPlaces.length < 3
                          ? _showAddDialog
                          : null,
                      backgroundColor: _selectedPlaces.length < 3
                          ? Colors.blue
                          : Colors.grey,
                      label: Text("장소 추가 (${_selectedPlaces.length}/3)"),
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // [하단] 선택된 장소 리스트 (이름만 표시 + 주요 거점 선택)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "자주 가는 장소 리스트 (클릭하여 주요 거점 설정)",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _selectedPlaces.isEmpty
                        ? const Center(child: Text("추가된 장소가 없습니다."))
                        : ListView.builder(
                            itemCount: _selectedPlaces.length,
                            itemBuilder: (context, index) {
                              final place = _selectedPlaces[index];
                              return Card(
                                elevation: place.isPrimary ? 4 : 1,
                                color: place.isPrimary
                                    ? Colors.blue[50]
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: place.isPrimary
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    place.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    place.isPrimary ? "★ 주요 거점" : "일반 장소",
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removePlace(index),
                                  ),
                                  onTap: () => _setPrimaryPlace(index),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. 장소 추가 팝업 (이름 확인 및 추가)
  void _showAddDialog() {
    TextEditingController nameController = TextEditingController(
      text: _currentMapName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("장소 추가"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("이 장소의 이름을 확인하거나 수정해주세요."),
            TextField(controller: nameController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedPlaces.add(
                  PlaceModel(
                    name: nameController.text,
                    latitude: _currentLat,
                    longitude: _currentLng,
                    // 첫 번째로 추가하는 장소는 자동으로 주요 거점 설정
                    isPrimary: _selectedPlaces.isEmpty,
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: const Text("리스트에 추가"),
          ),
        ],
      ),
    );
  }

  // 2. 주요 거점 설정 로직
  void _setPrimaryPlace(int index) {
    setState(() {
      for (var place in _selectedPlaces) {
        place.isPrimary = false;
      }
      _selectedPlaces[index].isPrimary = true;
    });
  }

  // 3. 장소 삭제
  void _removePlace(int index) {
    setState(() {
      bool wasPrimary = _selectedPlaces[index].isPrimary;
      _selectedPlaces.removeAt(index);
      // 삭제한 게 주요 거점이었다면 남은 것 중 첫 번째를 주요 거점으로
      if (wasPrimary && _selectedPlaces.isNotEmpty) {
        _selectedPlaces[0].isPrimary = true;
      }
    });
  }

  // 4. 최종 완료 및 데이터 전달
  void _finishSelection() {
    // List<PlaceModel>을 그대로 이전 페이지로 전달
    Navigator.pop(context, _selectedPlaces);
  }
}
