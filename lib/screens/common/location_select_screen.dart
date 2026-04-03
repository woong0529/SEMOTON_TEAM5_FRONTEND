import 'package:flutter/material.dart';
import '../../utils/place_model.dart';
import 'package:see_near_app/widgets/leaflet_map_widget.dart';


class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {

  final List<PlaceModel> _selectedPlaces = [];

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
            child: LeafletMapWidget(
              onLocationSelected: _handleLocationSelected,
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
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
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

  void _handleLocationSelected(String address, double lat, double lng) {
    if (_selectedPlaces.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('장소는 최대 3개까지만 등록 가능합니다.')));
      return;
    }

    setState(() {
      _selectedPlaces.add(PlaceModel(
        name: address,
        latitude: lat,
        longitude: lng,
        isPrimary: _selectedPlaces.isEmpty, // 첫 번째 장소면 자동 대표
      ));
    });
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
