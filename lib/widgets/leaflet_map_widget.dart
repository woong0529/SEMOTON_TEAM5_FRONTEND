import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeafletMapWidget extends StatefulWidget {
  final Function(String address, double lat, double lng)? onLocationSelected;
  const LeafletMapWidget({super.key, this.onLocationSelected});

  @override
  State<LeafletMapWidget> createState() => _LeafletMapWidgetState();
}

class _LeafletMapWidgetState extends State<LeafletMapWidget> {

  @override
  void initState() {
    super.initState();
    // WebView 플랫폼 초기화 (Android/iOS)
    WebViewPlatform.instance ??= AndroidWebViewPlatform();
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? '주소 없음';
      }
    } catch (e) {
      print('역지오코딩 오류: $e');
    }
    return '주소 조회 실패';
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'locationSelected',
          onMessageReceived: (JavaScriptMessage message) {
            final parts = message.message.split(',');
            if (parts.length == 2) {
              final lat = double.tryParse(parts[0]);
              final lng = double.tryParse(parts[1]);
              if (lat != null && lng != null) {
                _reverseGeocode(lat, lng).then((address) {
                  widget.onLocationSelected?.call(address, lat, lng);
                });
              }
            }
          },
        )
        ..loadFlutterAsset('assets/leaflet_map.html'),
    );
  }
}
