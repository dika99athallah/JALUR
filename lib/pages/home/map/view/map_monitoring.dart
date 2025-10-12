import 'dart:math' as math;

import 'package:JIR/helper/google_map_view.dart';
import 'package:JIR/pages/home/cctv/cctv_webview.dart';
import 'package:JIR/pages/home/cctv/model/cctv_location.dart';
import 'package:JIR/pages/home/map/controller/flood_controller.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';
import 'package:JIR/pages/home/map/widget/detail_flood.dart';
import 'package:JIR/pages/home/map/widget/menu_map_monitoring.dart';
import 'package:JIR/pages/home/map/widget/route_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show PatternItem;
import 'package:latlong2/latlong.dart' as ll;

class MapMonitoring extends StatelessWidget {
  final RouteController _routeController = Get.find<RouteController>();
  final TextEditingController _searchController = TextEditingController();
  final FloodController controller = Get.find<FloodController>();
  final FocusNode _searchFocusNode = FocusNode();
  final List<CCTVLocation> _cctvLocations =
      List<CCTVLocation>.from(defaultCctvLocations);

  MapMonitoring({super.key});

  @override
  Widget build(BuildContext context) {
    final savedDestination =
        _routeController.destinationAddress.value.isNotEmpty
            ? _routeController.destinationAddress.value
            : _routeController.destinationLabel.value;

    if (savedDestination.isNotEmpty &&
        _searchController.text.trim() != savedDestination.trim() &&
        !_searchFocusNode.hasFocus) {
      _searchController.text = savedDestination;
      _searchController.selection = TextSelection.collapsed(
        offset: _searchController.text.length,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Peta',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          _buildMap(context),
          _buildSearchSection(),
          _buildFloodMonitoringButton(context),
          _buildOptimizedRouteInfo(),
          _buildRouteSheet(),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return GetX<FloodController>(
      builder: (floodController) {
        if (floodController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final floodDataList = floodController.floodData.toList();
        final floodPositions = floodDataList.map((item) {
          final lat =
              double.tryParse(item['LATITUDE']?.toString() ?? '0.0') ?? 0.0;
          final lng =
              double.tryParse(item['LONGITUDE']?.toString() ?? '0.0') ?? 0.0;
          return ll.LatLng(lat, lng);
        }).toList();

        final cctvPositions =
            _cctvLocations.map((loc) => loc.coordinates).toList();

        final floodMarkerData = floodDataList.map((item) {
          final copy = Map<String, dynamic>.from(item);
          copy['markerType'] = 'flood';
          return copy;
        }).toList();

        final cctvMarkerData = _cctvLocations
            .map((loc) => {
                  'markerType': 'cctv',
                  'name': loc.name,
                  'url': loc.url,
                  'latitude': loc.coordinates.latitude,
                  'longitude': loc.coordinates.longitude,
                })
            .toList();

        final combinedMarkers = [...floodPositions, ...cctvPositions];
        final combinedMarkerData = [...floodMarkerData, ...cctvMarkerData];

        return GetX<RouteController>(
          builder: (routeController) {
            final routeOptions = routeController.routeOptions;
            final selectedRouteIndex = routeController.selectedRouteIndex.value;
            final trimmedActivePolyline = routeController.activeRoutePolyline
                .map((point) => ll.LatLng(point.latitude, point.longitude))
                .toList();
            final bool navigationMode = routeController.routeActive.value &&
                routeController.remainingRouteDistance.value > 0;
            final Set<String> trimmedPointKeys =
                trimmedActivePolyline.isNotEmpty
                    ? trimmedActivePolyline.map<String>(_latLngKey).toSet()
                    : <String>{};
            final List<RouteLineConfig> routeLines = [];
            final List<RouteBadgeConfig> routeBadges = [];
            const Color selectedRouteColor = Color(0xFF2563EB);
            const Color alternativeRouteColor = Color(0xFFF97316);
            const Color slowTrafficColor = Color(0xFFFFA000);
            const Color heavyTrafficColor = Color(0xFFD32F2F);
            final double fastestDurationSeconds = routeOptions.isEmpty
                ? 0.0
                : routeOptions
                    .map((option) => option.duration)
                    .reduce(math.min);

            final hasRouteSheet = routeOptions.isNotEmpty ||
                routeController.routeSteps.isNotEmpty ||
                routeController.isLoading.value;
            final media = MediaQuery.of(context);
            final collapsedSheetHeight = hasRouteSheet
                ? (media.size.height * 0.28) + media.padding.bottom + 24
                : 0.0;
            final bottomControlsPadding =
                hasRouteSheet ? collapsedSheetHeight : 32.0;

            for (var i = 0; i < routeOptions.length; i++) {
              final option = routeOptions[i];
              final isSelected = i == selectedRouteIndex;
              final optionPoints = option.points
                  .map((point) => ll.LatLng(point.latitude, point.longitude))
                  .toList();
              final bool hasTrimmedPath =
                  isSelected && trimmedActivePolyline.length >= 2;
              final pointsForRender =
                  hasTrimmedPath ? trimmedActivePolyline : optionPoints;

              routeLines.add(
                RouteLineConfig(
                  id: option.id,
                  points: pointsForRender,
                  color:
                      isSelected ? selectedRouteColor : alternativeRouteColor,
                  width: isSelected ? 7.0 : 5.0,
                  opacity: isSelected ? 0.98 : 0.65,
                  pattern: isSelected
                      ? null
                      : [
                          PatternItem.dash(40),
                          PatternItem.gap(24),
                        ],
                  zIndex: isSelected ? 3 : 1,
                ),
              );

              if (!isSelected && fastestDurationSeconds > 0) {
                final diffSeconds = option.duration - fastestDurationSeconds;
                final label = _formatRouteDifference(diffSeconds);
                final badgeAnchor = _routeBadgeAnchor(optionPoints);
                if (label != null && badgeAnchor != null) {
                  routeBadges.add(
                    RouteBadgeConfig(
                      id: option.id,
                      position: badgeAnchor,
                      label: label,
                      backgroundColor: Colors.white,
                      borderColor: alternativeRouteColor,
                      textColor: alternativeRouteColor,
                    ),
                  );
                }
              }

              if (option.trafficSegments.isNotEmpty) {
                for (var segIndex = 0;
                    segIndex < option.trafficSegments.length;
                    segIndex++) {
                  final segment = option.trafficSegments[segIndex];
                  final segmentPoints = segment.points
                      .map(
                          (point) => ll.LatLng(point.latitude, point.longitude))
                      .toList();

                  List<ll.LatLng> effectivePoints = segmentPoints;
                  if (hasTrimmedPath && trimmedPointKeys.isNotEmpty) {
                    effectivePoints = segmentPoints
                        .where(
                            (pt) => trimmedPointKeys.contains(_latLngKey(pt)))
                        .toList();
                    if (effectivePoints.length < 2) {
                      continue;
                    }
                  }

                  final Color trafficColor =
                      segment.severity == RouteTrafficSeverity.heavy
                          ? heavyTrafficColor
                          : slowTrafficColor;

                  routeLines.add(
                    RouteLineConfig(
                      id: '${option.id}_traffic_$segIndex',
                      points: effectivePoints,
                      color: trafficColor,
                      width: isSelected ? 8.0 : 6.0,
                      opacity: 0.95,
                      zIndex: isSelected ? 5 : 2,
                      clickable: false,
                    ),
                  );
                }
              }
            }

            final waypointPositions = routeController.optimizedWaypoints
                .map((point) => ll.LatLng(point.latitude, point.longitude))
                .toList();
            final userLoc = routeController.userLocation.value;
            final userPosition = userLoc != null
                ? ll.LatLng(userLoc.latitude, userLoc.longitude)
                : null;
            final dest = routeController.destination.value;
            final destinationPoint =
                dest != null ? ll.LatLng(dest.latitude, dest.longitude) : null;

            return JirMapView(
              initialLocation: userPosition ??
                  (combinedMarkers.isNotEmpty ? combinedMarkers.first : null),
              markers: combinedMarkers,
              markerData: combinedMarkerData,
              userLocation: userPosition,
              userHeading: routeController.userHeading.value,
              routeLines: routeLines,
              waypoints: waypointPositions,
              destination: destinationPoint,
              navigationMode: navigationMode,
              onMarkerDataTap: _handleMarkerDataTap,
              onRouteTap: (routeId) => routeController.selectRouteById(
                routeId,
                showFeedback: true,
              ),
              enableMyLocation: true,
              bottomControlsPadding: bottomControlsPadding,
              routeBadges: routeBadges,
            );
          },
        );
      },
    );
  }

  Widget _buildOptimizedRouteInfo() {
    return Positioned(
      top: 80,
      right: 16,
      child: GetX<RouteController>(
        builder: (controller) {
          if (controller.optimizedWaypoints.isEmpty) {
            return const SizedBox();
          }

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rute Dioptimalkan',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.optimizedWaypoints.length} waypoint',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          _buildSearchBar(),
          Obx(() => _buildSearchSuggestions()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Masukkan tujuan...',
          hintStyle: GoogleFonts.inter(
            color: Colors.black,
            fontStyle: FontStyle.italic,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (_, value, __) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                onPressed: () {
                  _clearSearch();
                  _searchFocusNode.unfocus();
                },
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        onTap: () {
          if (_searchController.text.isEmpty) {
            _searchFocusNode.requestFocus();
          }
        },
        onChanged: (value) {
          if (value.isEmpty) {
            _routeController.clearRoute();
            _searchFocusNode.unfocus();
          }
          _routeController.handleSearch(value);
        },
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Visibility(
      visible: _routeController.searchSuggestions.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: _routeController.searchSuggestions.length,
          itemBuilder: (context, index) => _buildSuggestionItem(index),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(int index) {
    final suggestion = _routeController.searchSuggestions[index];
    final distanceText = _getSuggestionDistanceText(suggestion);

    return ListTile(
      leading: const Icon(Icons.location_on, size: 20),
      title: Text(suggestion['display_name'] ?? 'Lokasi'),
      subtitle: _buildSuggestionSubtitle(suggestion, distanceText),
      onTap: () => _handleSuggestionTap(suggestion),
    );
  }

  Widget _buildSuggestionSubtitle(dynamic suggestion, String? distanceText) {
    final displayName = suggestion['display_name']?.toString() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((suggestion['place_name'] ?? '').toString().isNotEmpty &&
            suggestion['place_name'] != displayName)
          Text(
            suggestion['place_name'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        Text(
          RouteController.getLocationType(
              (suggestion['type'] ?? '').toString()),
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.blue,
          ),
        ),
        if (distanceText != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '≈ $distanceText',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  String? _getSuggestionDistanceText(dynamic suggestion) {
    if (suggestion is! Map<String, dynamic>) return null;

    final cached = suggestion['distance_text']?.toString();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final location = suggestion['location'];
    final userPosition = _routeController.userLocation.value;
    if (location is! Map || userPosition == null) {
      return null;
    }

    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      return null;
    }

    final target = ll.LatLng(lat, lng);
    final distanceMeters =
        RouteController.calculateDistance(userPosition, target);
    final formatted = RouteController.formatDistance(distanceMeters);
    suggestion['distance_meters'] = distanceMeters;
    suggestion['distance_text'] = formatted;
    return formatted;
  }

  Future<void> _handleSuggestionTap(dynamic suggestion) async {
    _routeController.searchSuggestions.clear();
    await _routeController.selectDestinationSuggestion(suggestion);
    final resolvedAddress = _routeController.destinationAddress.value.isNotEmpty
        ? _routeController.destinationAddress.value
        : _routeController.destinationLabel.value;
    if (resolvedAddress.isNotEmpty) {
      _searchController.text = resolvedAddress;
      _searchController.selection = TextSelection.collapsed(
        offset: _searchController.text.length,
      );
    }
    _searchFocusNode.unfocus();
  }

  Widget _buildFloodMonitoringButton(BuildContext context) {
    return GetX<RouteController>(
      builder: (controller) {
        final hasRouteSheet = controller.routeOptions.isNotEmpty ||
            controller.routeSteps.isNotEmpty ||
            controller.isLoading.value;
        final media = MediaQuery.of(context);
        final collapsedSheetHeight = hasRouteSheet
            ? (media.size.height * 0.28) + media.padding.bottom + 36
            : 50.0;
        return Positioned(
          bottom: collapsedSheetHeight,
          left: 20,
          child: const AnimatedMenuButton(),
        );
      },
    );
  }

  Widget _buildRouteSheet() {
    return GetX<RouteController>(
      builder: (controller) {
        final hasContent = controller.routeOptions.isNotEmpty ||
            controller.routeSteps.isNotEmpty ||
            controller.isLoading.value;
        if (!hasContent) {
          return const SizedBox.shrink();
        }
        return Align(
          alignment: Alignment.bottomCenter,
          child: RouteBottomSheetWidget(
            key: const ValueKey('route-bottom-sheet'),
          ),
        );
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _routeController.searchSuggestions.clear();
    _routeController.clearRoute();
  }

  String _latLngKey(ll.LatLng value) {
    final lat = value.latitude.toStringAsFixed(5);
    final lng = value.longitude.toStringAsFixed(5);
    return '$lat|$lng';
  }

  String? _formatRouteDifference(double seconds) {
    if (seconds <= 30) return null;
    final diffMinutes = (seconds / 60).ceil();
    if (diffMinutes <= 0) return null;
    return '+$diffMinutes menit';
  }

  ll.LatLng? _routeBadgeAnchor(List<ll.LatLng> points) {
    if (points.isEmpty) return null;
    final index = (points.length * 0.6).round().clamp(0, points.length - 1);
    return points[index];
  }

  void _handleMarkerDataTap(Map<String, dynamic> item) {
    final markerType = item['markerType']?.toString().toLowerCase();
    if (markerType == 'cctv') {
      _showCctvDetails(item);
      return;
    }
    _showDisasterDetails(item);
  }

  void _showDisasterDetails(Map<String, dynamic> item) {
    final lat = double.tryParse(item['LATITUDE'].toString());
    final lng = double.tryParse(item['LONGITUDE'].toString());

    if (lat == null || lng == null) {
      Get.snackbar("Error", "Koordinat tidak valid");
      return;
    }

    Get.bottomSheet(
      DisasterBottomSheet(
        location: item['NAMA_PINTU_AIR'] ?? 'Lokasi Tidak Diketahui',
        status: item['STATUS_SIAGA']?.toString() ?? 'N/A',
        onViewLocation: () {
          Get.back();
          final context = Get.context;
          if (context != null) {
            controller.navigateToFloodMonitoring(context, item);
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showCctvDetails(Map<String, dynamic> item) {
    final name = (item['name'] ?? 'CCTV').toString();
    final url = item['url']?.toString();
    final latitude = item['latitude'];
    final longitude = item['longitude'];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Detail CCTV',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff45557B),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.videocam,
                  color: Color(0xff45557B), size: 28),
              title: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: (latitude is num && longitude is num)
                  ? Text(
                      'Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)}',
                      style: GoogleFonts.inter(fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: url == null
                    ? null
                    : () {
                        Get.back();
                        Get.to(() => CCTVWebView(url: url));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff45557B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.open_in_new),
                label: Text(
                  'Buka CCTV',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
