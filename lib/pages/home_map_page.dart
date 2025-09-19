import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:soireesafe/constants.dart';
import 'package:soireesafe/services/bar_service.dart';
import 'package:soireesafe/pages/bars_list_page.dart';
import 'package:soireesafe/pages/bar_detail_page.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key});

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  MapLibreMapController? mapController;
  final BarService _svc = BarService();
  List<Map<String, dynamic>> bars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBars();
  }

  Future<void> _loadBars() async {
    try {
      final barStats = await _svc.fetchBarStats();
      setState(() {
        bars = List<Map<String, dynamic>>.from(barStats);
        isLoading = false;
      });
      _addMarkersToMap();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    _addMarkersToMap();
  }

  Future<void> _addMarkersToMap() async {
    if (mapController == null || bars.isEmpty) {
      return;
    }

    for (final bar in bars) {
      final lat = (bar['lat'] as num?)?.toDouble();
      final lng = (bar['lng'] as num?)?.toDouble();
      final noteMoy = (bar['note_moy'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        continue;
      }
      await mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(lat, lng),
          textField: noteMoy?.toStringAsFixed(1) ?? '—',
          textColor: '#FFFFFF',
          textSize: 12,
          textOffset: const Offset(0, 0),
          iconImage: 'marker-15',
        ),
      );
    }

    mapController!.onSymbolTapped.add(_onMarkerTapped);
  }

  void _onMarkerTapped(Symbol symbol) {
    final tappedLatLng = symbol.options.geometry;
    if (tappedLatLng == null) {
      return;
    }

    // Find the bar that matches the tapped marker
    final bar = bars.firstWhere(
      (b) =>
          ((b['lat'] as num?)?.toDouble() ?? 0 - tappedLatLng.latitude).abs() <
              0.0001 &&
          ((b['lng'] as num?)?.toDouble() ?? 0 - tappedLatLng.longitude).abs() <
              0.0001,
      orElse: () => bars.first,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            BarDetailPage(barId: (bar['id'] ?? bar['bar_id']).toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SoireeSafe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BarsListPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MapLibreMap(
                  styleString: Constants.styleUrl,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(
                      Constants.marseilleLatitude,
                      Constants.marseilleLongitude,
                    ),
                    zoom: 13.0,
                  ),
                  trackCameraPosition: true,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_bar,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Bars à Marseille',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${bars.length} établissements référencés',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
