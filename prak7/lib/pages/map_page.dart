import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../models/location_model.dart';
import '../widgets/custom_marker.dart';

/// Main map screen for KulinerHunt implementing GPS and Pin Point flows.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();

  // Center defaults to Surabaya (example coordinates).
  LatLng _currentCenter = const LatLng(-7.2575, 112.7521);

  // Parsed location models fetched from API.
  List<LocationModel> _locations = [];

  // Whether user is in Pin Point (Pick on Map) mode.
  bool _isPinPointMode = false;

  // Temporary pin coordinate while selecting manually.
  LatLng? _tempPickedPoint;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  /// Fetch remote locations and rebuild markers.
  Future<void> _fetchLocations() async {
    try {
      final fetched = await _apiService.getLocations();
      if (!mounted) return;
      setState(() {
        _locations = fetched;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_locations.length} lokasi dimuat'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Allow app to work even if API fails
      setState(() {
        _locations = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Peringatan: Gagal memuat data dari server. Anda masih bisa menambah lokasi baru.'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Coba Lagi',
            onPressed: _fetchLocations,
          ),
        ),
      );
    }
  }

  /// Entry point when user taps the main FAB to add a location.
  void _onAddLocationPressed() {
    _showAddModeSheet();
  }

  /// Displays a bottom sheet to choose between GPS and manual pin point.
  void _showAddModeSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tambah Lokasi Kuliner',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.my_location, color: Colors.white),
                ),
                title: const Text('Gunakan GPS Saat Ini'),
                subtitle: const Text('Ambil koordinat lokasi perangkat.'),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleGpsAdd();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.place, color: Colors.white),
                ),
                title: const Text('Pilih di Peta (Pin Point)'),
                subtitle: const Text('Geser dengan men-tap di peta.'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _isPinPointMode = true;
                    _tempPickedPoint = _currentCenter; // start at center.
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Obtain current GPS position then ask for name via bottom sheet.
  Future<void> _handleGpsAdd() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      _mapController.move(point, 16);
      if (!mounted) return;
      _showNameInputSheet(point);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GPS gagal: $e')),
      );
    }
  }

  /// Bottom sheet to input place/menu name then persist new Location.
  void _showNameInputSheet(LatLng position) {
    final TextEditingController nameController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Nama Tempat / Menu',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Masukkan nama kuliner',
                  hintText: 'Misal: Nasi Goreng Pak Kumis',
                  prefixIcon: Icon(Icons.fastfood, color: Colors.orange),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final text = nameController.text.trim();
                    if (text.isEmpty) return;
                    Navigator.pop(ctx);
                    await _persistNewLocation(text, position);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Rekomendasi'),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() => nameController.dispose());
  }

  /// Persists a new location to server and refreshes markers.
  Future<void> _persistNewLocation(String name, LatLng position) async {
    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Menyimpan...')
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    final newLoc = LocationModel(
      id: '',
      name: name,
      latitude: position.latitude,
      longitude: position.longitude,
    );
    print('Saving location: $name at (${position.latitude}, ${position.longitude})');
    final success = await _apiService.addLocation(newLoc);
    // Clear loading message
    ScaffoldMessenger.of(context).clearSnackBars();
    if (!mounted) return;
    if (success) {
      print('Location saved successfully!');
      await _fetchLocations();
      _mapController.move(position, 16);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Rekomendasi berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('Failed to save location');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✗ Gagal menyimpan. Periksa koneksi internet Anda.'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: () => _persistNewLocation(name, position),
          ),
        ),
    
      );
    }
    // Exit pin point mode after saving (if active).
    setState(() {
      _isPinPointMode = false;
      _tempPickedPoint = null;
    });
  }

  /// Builds permanent markers from loaded locations + temporary selection if any.
  List<Marker> _buildMarkers() {
    final List<Marker> markers = _locations.map((loc) {
      return Marker(
        width: 140,
        height: 120,
        point: LatLng(loc.latitude, loc.longitude),
        child: CustomMarker(placeName: loc.name),
      );
    }).toList();

    if (_isPinPointMode && _tempPickedPoint != null) {
      markers.add(
        Marker(
          width: 140,
          height: 120,
          point: _tempPickedPoint!,
          child: const CustomMarker(
            placeName: 'Pilih Lokasi…',
            isTemporary: true,
          ),
        ),
      );
    }
    return markers;
  }

  /// Handle taps on map only when in pin point mode.
  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    if (!_isPinPointMode) return;
    setState(() {
      _tempPickedPoint = latLng;
    });
  }

  /// Confirm selection in pin point mode (if a temp point exists).
  void _confirmPinPoint() {
    final point = _tempPickedPoint;
    if (point == null) return;
    _showNameInputSheet(point);
  }

  /// Cancel pin point mode and clear temporary state.
  void _cancelPinPoint() {
    setState(() {
      _isPinPointMode = false;
      _tempPickedPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KulinerHunt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLocations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 14.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kuliner.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          if (_isPinPointMode)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app, color: Colors.orange),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tap peta untuk memindahkan pin. Tekan "Konfirmasi" untuk menyimpan.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _cancelPinPoint,
                        tooltip: 'Batal',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isPinPointMode)
                  FloatingActionButton.extended(
                    onPressed: _confirmPinPoint,
                    heroTag: 'confirmPin',
                    backgroundColor: Colors.green,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
                  ),
                const SizedBox(height: 12),
                if (!_isPinPointMode)
                  FloatingActionButton.extended(
                    onPressed: _onAddLocationPressed,
                    heroTag: 'addLoc',
                    backgroundColor: Colors.orange,
                    icon: const Icon(Icons.add_location_alt, color: Colors.white),
                    label: const Text('Rekomendasiin!', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
