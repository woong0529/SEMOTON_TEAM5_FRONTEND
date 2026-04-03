import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Android용 추가 설정 (필요 시)
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeafletMapWidget extends StatefulWidget {
  final Function(String address, double lat, double lng)? onLocationSelected;
  const LeafletMapWidget({super.key, this.onLocationSelected});

  @override
  State<LeafletMapWidget> createState() => _LeafletMapWidgetState();
}

class _LeafletMapWidgetState extends State<LeafletMapWidget> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    // 컨트롤러 설정을 별도 함수로 분리하여 한 번만 호출되게 합니다.
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) =>
              print("❌ 웹 리소스 에러: ${error.description}"),
          onPageFinished: (url) => print("✅ 페이지 로드 완료"),
        ),
      )
      ..addJavaScriptChannel(
        'locationSelected',
        onMessageReceived: (message) {
          final data = json.decode(message.message);
          _handleLocationData(data['lat'], data['lng']);
        },
      )
      // 🔥 파일 경로가 정확한지 다시 한번 확인하세요! (assets/leaflet_map.html)
      ..loadFlutterAsset('assets/leaflet_map.html');

    setState(() {
      _controller = controller;
    });
  }

  // 데이터 처리 로직
  Future<void> _handleLocationData(double lat, double lng) async {
    final address = await _reverseGeocode(lat, lng);
    widget.onLocationSelected?.call(address, lat, lng);
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';
    try {
      // Nominatim 이용 시 User-Agent 헤더 권장
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Flutter_Map_App'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? '주소 정보 없음';
      }
    } catch (e) {
      print('역지오코딩 오류: $e');
    }
    return '주소 조회 실패';
  }

  @override
  Widget build(BuildContext context) {
  // 1. 컨트롤러가 아직 초기화 전(Null)이라면 로딩 화면을 보여줍니다.
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

  // 2. 여기서 '!'를 붙여서 "이건 절대 Null이 아니야"라고 확신을 줍니다.
    return WebViewWidget(controller: _controller!);
  }
}