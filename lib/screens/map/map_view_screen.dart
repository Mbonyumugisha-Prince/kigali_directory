import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../directory/listing_detail_screen.dart';

// Kigali city centre (openstreetmap.org/#map=9/-1.955/29.883)
const _kigaliCenter = LatLng(-1.9441, 30.0619);

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();
    final listings = provider.all;
    final pinned   = listings.where((l) => l.hasCoordinates).toList();

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(
        children: [
          // ── Full-screen OSM Map ──────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _kigaliCenter,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kigaliDirectory',
              ),

              // ── Markers for every listing that has coordinates ───────
              MarkerLayer(
                markers: pinned.map((listing) {
                  return Marker(
                    point: LatLng(listing.latitude, listing.longitude),
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ListingDetailScreen(listing: listing),
                        ),
                      ),
                      child: Tooltip(
                        message: listing.name,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _categoryIcon(listing.category),
                            color: AppColors.darkNavy,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── Header overlay ───────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkNavy.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.navyBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_rounded,
                        color: AppColors.accent, size: 20),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Map View',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            )),
                        Text(
                          '${pinned.length} of ${listings.length} '
                          'listing${listings.length == 1 ? '' : 's'} pinned',
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 11),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Re-centre button
                    GestureDetector(
                      onTap: () =>
                          _mapController.move(_kigaliCenter, 12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                            Icons.center_focus_strong_rounded,
                            color: AppColors.accent,
                            size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── "No pins" hint when no listing has coordinates ───────────
          if (listings.isNotEmpty && pinned.isEmpty)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.navyBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.textHint, size: 16),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Add coordinates to listings so they appear as pins on the map.',
                        style: TextStyle(
                            color: AppColors.textHint, fontSize: 12),
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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Hospital':           return Icons.local_hospital_rounded;
      case 'Police Station':     return Icons.local_police_rounded;
      case 'Library':            return Icons.local_library_rounded;
      case 'Restaurant':         return Icons.restaurant_rounded;
      case 'Café':               return Icons.coffee_rounded;
      case 'Park':               return Icons.park_rounded;
      case 'Tourist Attraction': return Icons.camera_alt_rounded;
      default:                   return Icons.place_rounded;
    }
  }
}
