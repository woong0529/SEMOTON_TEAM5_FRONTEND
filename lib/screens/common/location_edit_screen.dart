import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../utils/place_model.dart';
import '../../services/location_service.dart'; // LocationService 임포트 확인
import 'package:see_near_app/widgets/leaflet_map_widget.dart';



class LocationEditScreen extends StatefulWidget {
  // 마이페이지에서 진입할 때 서버에서 받은 기존 리스트를 넘겨줍니다.
  final List<PlaceModel> initialLocations;

  const LocationEditScreen({super.key, required this.initialLocations});

  @override
  State<LocationEditScreen> createState() => _LocationEditScreenState();
}

class _LocationEditScreenState extends State<LocationEditScreen> {
  late List<PlaceModel> _editingLocations;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    // 부모로부터 받은 데이터를 복사하여 편집용 리스트 초기화
    _editingLocations = List.from(widget.initialLocations);
  }

  // 서버에 수정된 리스트 저장
  Future<void> _handleSave() async {
    if (_editingLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 한 개의 위치는 지정해야 합니다.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // 서비스 호출 (LocationService에 updateMyLocations 함수가 있다고 가정)
    final res = await LocationService.updateMyLocations(_editingLocations);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.success) {
      Navigator.pop(context, _editingLocations); // 수정된 데이터 들고 복귀
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? '저장 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('활동 거점 수정', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _handleSave,
              child: const Text('저장', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. 지도 영역 (LeafletMapWidget)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: LeafletMapWidget(
              onLocationSelected: _handleLocationSelected,
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.subText),
                SizedBox(width: 4),
                Text('지도를 탭하여 새 장소를 추가하세요 (최대 3개)', style: TextStyle(fontSize: 13, color: AppColors.subText)),
              ],
            ),
          ),

          // 2. 편집 리스트 영역
          Expanded(
            child: _buildLocationList(),
          ),
        ],
      ),
    );
  }

  // 지도에서 위치 선택 시 호출
  void _handleLocationSelected(String address, double lat, double lng) {
    if (_editingLocations.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('장소는 최대 3개까지만 등록 가능합니다.')));
      return;
    }

    setState(() {
      _editingLocations.add(PlaceModel(
        name: address,
        latitude: lat,
        longitude: lng,
        isPrimary: _editingLocations.isEmpty, // 첫 번째 장소면 자동 대표
      ));
    });
  }

  // 리스트 빌더 위젯
  Widget _buildLocationList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _editingLocations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final place = _editingLocations[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: place.isPrimary ? AppColors.primary : Colors.transparent, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: IconButton(
              icon: Icon(
                place.isPrimary ? Icons.stars_rounded : Icons.stars_outlined,
                color: place.isPrimary ? AppColors.primary : Colors.grey,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  for (var p in _editingLocations) { p.isPrimary = false; }
                  place.isPrimary = true;
                });
              },
            ),
            title: Text(
              place.name, 
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Text(place.isPrimary ? '주요 거점' : '활동 거점', style: TextStyle(color: place.isPrimary ? AppColors.primary : AppColors.subText)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                if (_editingLocations.length <= 1) return;
                setState(() {
                  _editingLocations.removeAt(index);
                  if (place.isPrimary && _editingLocations.isNotEmpty) {
                    _editingLocations[0].isPrimary = true;
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }
}