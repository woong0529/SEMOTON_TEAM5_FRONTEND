import 'package:flutter/material.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import '../../core/app_colors.dart';
import '../../widgets/app_button.dart';

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



class JobLocationPicker extends StatefulWidget {
  const JobLocationPicker({super.key});

  @override
  State<JobLocationPicker> createState() => _JobLocationPickerState();
}

class _JobLocationPickerState extends State<JobLocationPicker> {
  PlaceModel? _selectedPlace; // 단 하나만 저장
  final String kakaoApiKey = "YOUR_JAVASCRIPT_APP_KEY";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('공고 장소 선택', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. 지도 영역
          Expanded(
            child: Stack(
              children: [
                KakaoMapView(
                  width: MediaQuery.of(context).size.width,
                  height: double.infinity,
                  kakaoApiKey: kakaoApiKey,
                  onTap: (KakaoMapTapResponse response) {
                    setState(() {
                      _selectedPlace = PlaceModel(
                        name: response.address ?? "선택한 장소",
                        latitude: response.latLng.latitude,
                        longitude: response.latLng.longitude,
                        isPrimary: true, // 단일 장소이므로 무조건 true
                      );
                    });
                  },
                ),
                // 지도가 비어있을 때 안내 문구
                if (_selectedPlace == null)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Text(
                        '📍 공고를 진행할 위치를 지도를 클릭해 선택해주세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. 하단 선택 정보 및 확정 버튼
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('선택된 장소', style: TextStyle(color: AppColors.subText, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.place, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedPlace?.name ?? "지도를 클릭해주세요",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: '이 위치로 확정하기',
                    onTap: (_selectedPlace == null ? () {} : () =>Navigator.pop(context, _selectedPlace)) // 선택 안 되면 버튼 비활성화
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}