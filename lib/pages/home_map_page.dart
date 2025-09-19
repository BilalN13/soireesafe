import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:soireesafe/constants.dart';
import 'package:soireesafe/pages/bar_detail_page.dart';
import 'package:soireesafe/pages/bars_list_page.dart';
import 'package:soireesafe/services/bar_service.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key});

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  final BarService _svc = BarService();
  MapLibreMapController? _mapController;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _bars = [];

  @override
  void initState() {
    super.initState();
    _loadBars();
  }

  Future<void> _loadBars() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _svc.fetchBarStats();
      if (!mounted) {
        return;
      }
      setState(() {
        _bars = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
      await _addMarkersToMap();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    controller.onSymbolTapped.add(_onMarkerTapped);
    _addMarkersToMap();
  }

  Future<void> _addMarkersToMap() async {
    final controller = _mapController;
    if (controller == null || _bars.isEmpty) {
      return;
    }

    await controller.clearSymbols();

    for (final bar in _bars) {
      final lat = (bar['lat'] as num?)?.toDouble();
      final lng = (bar['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        continue;
      }
      final noteMoy = (bar['note_moy'] as num?)?.toDouble();
      final barId = (bar['id'] ?? bar['bar_id']).toString();

      await controller.addSymbol(
        SymbolOptions(
          geometry: LatLng(lat, lng),
          iconImage: 'marker-15',
          textField: noteMoy?.toStringAsFixed(1) ?? '--',
          textColor: '#FFFFFF',
          textOffset: const Offset(0, -1.2),
          textSize: 12,
        ),
        <String, dynamic>{
          'barId': barId,
        },
      );
    }
  }

  void _onMarkerTapped(Symbol symbol) {
    final data = symbol.data;
    String? barId;

    if (data is Map && data['barId'] != null) {
      barId = data['barId'].toString();
    } else {
      final tappedLatLng = symbol.options.geometry;
      if (tappedLatLng != null) {
        final match = _bars.firstWhere(
          (bar) {
            final lat = (bar['lat'] as num?)?.toDouble();
            final lng = (bar['lng'] as num?)?.toDouble();
            if (lat == null || lng == null) {
              return false;
            }
            return (lat - tappedLatLng.latitude).abs() < 0.0001 &&
                (lng - tappedLatLng.longitude).abs() < 0.0001;
          },
          orElse: () => <String, dynamic>{},
        );
        if (match.isNotEmpty) {
          barId = (match['id'] ?? match['bar_id']).toString();
        }
      }
    }

    if (barId == null) {
      return;
    }

    final String selectedId = barId;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarDetailPage(barId: selectedId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Erreur: $_error'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadBars,
              child: const Text('Reessayer'),
            ),
          ],
        ),
      );
    } else {
      body = Stack(
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
                            'Bars a Marseille',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${_bars.length} etablissements references',
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
      );
    }

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
      body: body,
    );
  }

  @override
  void dispose() {
    _mapController?.onSymbolTapped.remove(_onMarkerTapped);
    _mapController?.dispose();
    super.dispose();
  }
}
