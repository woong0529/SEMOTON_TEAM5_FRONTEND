import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';

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
  final String kakaoMapKey = 'cf6745f93536af237f2050123f8b0659';

  final List<PlaceModel> _selectedPlaces = [];

  double _currentLat = 37.5665;
  double _currentLng = 126.9780;
  String _currentMapName = '선택한 위치';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('장소 설정'),
        actions: [
          TextButton(
            onPressed: _selectedPlaces.isNotEmpty ? _finishSelection : null,
            child: const Text(
              '완료',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: KakaoMapView(
                    width: MediaQuery.of(context).size.width,
                    height: double.infinity,
                    kakaoMapKey: kakaoMapKey,
                    lat: _currentLat,
                    lng: _currentLng,
                    showMapTypeControl: true,
                    showZoomControl: true,
                    onTapMarker: _handleMapTapMessage,
                    customScript: _buildKakaoMapScript(),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton.extended(
                    onPressed: _selectedPlaces.length < 3 ? _showAddDialog : null,
                    backgroundColor:
                        _selectedPlaces.length < 3 ? Colors.blue : Colors.grey,
                    label: Text('장소 추가 (${_selectedPlaces.length}/3)'),
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '장소 목록 (눌러서 주요 장소 설정)',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _selectedPlaces.isEmpty
                        ? const Center(child: Text('추가된 장소가 없습니다.'))
                        : ListView.builder(
                            itemCount: _selectedPlaces.length,
                            itemBuilder: (context, index) {
                              final place = _selectedPlaces[index];
                              return Card(
                                elevation: place.isPrimary ? 4 : 1,
                                color:
                                    place.isPrimary ? Colors.blue[50] : Colors.white,
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
                                    place.isPrimary ? '주요 장소' : '일반 장소',
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

  void _handleMapTapMessage(message) {
    try {
      final decoded = jsonDecode(message.message);
      if (decoded is Map<String, dynamic>) {
        final tappedLat = (decoded['lat'] as num?)?.toDouble();
        final tappedLng = (decoded['lng'] as num?)?.toDouble();
        final tappedName = decoded['name']?.toString();

        setState(() {
          if (tappedLat != null) {
            _currentLat = tappedLat;
          }
          if (tappedLng != null) {
            _currentLng = tappedLng;
          }
          _currentMapName =
              (tappedName != null && tappedName.isNotEmpty)
                  ? tappedName
                  : '선택한 위치';
        });
        return;
      }
    } catch (_) {
      // Ignore malformed messages and fall back to the default label.
    }

    setState(() {
      _currentMapName = '선택한 위치';
    });
  }

  String _buildKakaoMapScript() {
    return '''
const zoomControl = new kakao.maps.ZoomControl();
map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

const mapTypeControl = new kakao.maps.MapTypeControl();
map.addControl(mapTypeControl, kakao.maps.ControlPosition.TOPRIGHT);

const serviceScript = document.createElement('script');
serviceScript.src = 'https://dapi.kakao.com/v2/maps/sdk.js?appkey=$kakaoMapKey&libraries=services';
serviceScript.onload = function() {
  const attachTapListener = function(geocoder) {
    kakao.maps.event.addListener(map, 'click', function(mouseEvent) {
      const lat = mouseEvent.latLng.getLat();
      const lng = mouseEvent.latLng.getLng();

      map.setCenter(new kakao.maps.LatLng(lat, lng));

      if (geocoder) {
        geocoder.coord2Address(lng, lat, function(result, status) {
          let placeName = '선택한 위치';

          if (status === kakao.maps.services.Status.OK && result.length > 0) {
            const item = result[0];
            if (item.road_address && item.road_address.address_name) {
              placeName = item.road_address.address_name;
            } else if (item.address && item.address.address_name) {
              placeName = item.address.address_name;
            }
          }

          onTapMarker.postMessage(JSON.stringify({
            lat: lat,
            lng: lng,
            name: placeName
          }));
        });
        return;
      }

      onTapMarker.postMessage(JSON.stringify({
        lat: lat,
        lng: lng,
        name: '선택한 위치'
      }));
    });
  };

  if (kakao.maps.services && kakao.maps.services.Geocoder) {
    attachTapListener(new kakao.maps.services.Geocoder());
  } else {
    attachTapListener(null);
  }
};

serviceScript.onerror = function() {
  kakao.maps.event.addListener(map, 'click', function(mouseEvent) {
    const lat = mouseEvent.latLng.getLat();
    const lng = mouseEvent.latLng.getLng();

    map.setCenter(new kakao.maps.LatLng(lat, lng));

    onTapMarker.postMessage(JSON.stringify({
      lat: lat,
      lng: lng,
      name: '선택한 위치'
    }));
  });
};

document.head.appendChild(serviceScript);
''';
  }

  void _showAddDialog() {
    TextEditingController nameController =
        TextEditingController(text: _currentMapName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('장소 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('선택한 장소의 이름을 확인하거나 수정해주세요.'),
            TextField(controller: nameController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedPlaces.add(
                  PlaceModel(
                    name: nameController.text,
                    latitude: _currentLat,
                    longitude: _currentLng,
                    isPrimary: _selectedPlaces.isEmpty,
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('목록에 추가'),
          ),
        ],
      ),
    );
  }

  void _setPrimaryPlace(int index) {
    setState(() {
      for (var place in _selectedPlaces) {
        place.isPrimary = false;
      }
      _selectedPlaces[index].isPrimary = true;
    });
  }

  void _removePlace(int index) {
    setState(() {
      final wasPrimary = _selectedPlaces[index].isPrimary;
      _selectedPlaces.removeAt(index);
      if (wasPrimary && _selectedPlaces.isNotEmpty) {
        _selectedPlaces[0].isPrimary = true;
      }
    });
  }

  void _finishSelection() {
    Navigator.pop(context, _selectedPlaces);
  }
}
