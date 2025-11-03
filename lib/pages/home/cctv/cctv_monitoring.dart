import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:JIR/helper/google_map_view.dart';
import 'package:JIR/pages/home/cctv/cctv_webview.dart';
import 'package:JIR/pages/home/cctv/model/cctv_location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:get/get.dart';

class CCTVPage extends StatefulWidget {
  const CCTVPage({super.key});

  @override
  State<CCTVPage> createState() => _CCTVPageState();
}

class _CCTVPageState extends State<CCTVPage> {
  final List<CCTVLocation> _cctvLocations =
      List<CCTVLocation>.from(defaultCctvLocations);
  late final TextEditingController _searchController;
  late List<CCTVLocation> _filteredLocations;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredLocations = List<CCTVLocation>.from(_cctvLocations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markerPositions = _cctvLocations
        .map((loc) =>
            ll.LatLng(loc.coordinates.latitude, loc.coordinates.longitude))
        .toList();

    final markerData = _cctvLocations
        .map((loc) => {
              'markerType': 'cctv',
              'name': loc.name,
              'url': loc.url,
              'latitude': loc.coordinates.latitude,
              'longitude': loc.coordinates.longitude,
            })
        .toList();

    final initialLocation = markerPositions.isNotEmpty
        ? markerPositions.first
        : ll.LatLng(-6.2000, 106.8167);

    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      appBar: AppBar(
        backgroundColor: const Color(0xFF45557B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text(
          'Pantau CCTV',
          style: GoogleFonts.lexend(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitor kondisi kota secara real-time dari CCTV unggulan.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xff6b7280),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _buildSearchField(),
                  SizedBox(height: 16.h),
                  _buildMapPreview(
                    context,
                    initialLocation,
                    markerPositions,
                    markerData,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredLocations.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                      itemCount: _filteredLocations.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        return _CctvCard(
                          location: location,
                          onTap: () => _navigateToCCTV(
                              context, location.name, location.url),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterLocations,
        style:
            GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xff1f2a44)),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded,
              color: const Color(0xff9ca3af), size: 22.sp),
          hintText: 'Cari lokasi CCTV... ',
          hintStyle: GoogleFonts.inter(
            fontSize: 13.sp,
            color: const Color(0xff9ca3af),
          ),
          border: InputBorder.none,
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () {
                  _searchController.clear();
                  _filterLocations('');
                },
                icon: Icon(Icons.close_rounded,
                    color: const Color(0xff9ca3af), size: 20.sp),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview(
    BuildContext context,
    ll.LatLng initialLocation,
    List<ll.LatLng> markers,
    List<Map<String, dynamic>> markerData,
  ) {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff4f8eff), Color(0xff203a83)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            JirMapView(
              initialLocation: initialLocation,
              markers: markers,
              markerData: markerData,
              enableMyLocation: false,
              autoFitBounds: true,
              onMarkerDataTap: (item) {
                final url = item['url'];
                if (url == null) {
                  Get.snackbar(
                    'Tidak dapat membuka',
                    'Link CCTV tidak tersedia',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                _openCCTV(
                  context,
                  item['name']?.toString() ?? 'CCTV',
                  url.toString(),
                );
              },
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Peta CCTV',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff1f2a44),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${_cctvLocations.length} titik terhubung',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: const Color(0xff4b5563),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded,
                size: 48.sp, color: const Color(0xff9ca3af)),
            SizedBox(height: 12.h),
            Text(
              'CCTV tidak ditemukan',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xff1f2a44),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Coba gunakan kata kunci lain atau telusuri langsung melalui peta.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xff6b7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterLocations(String query) {
    final trimmed = query.trim().toLowerCase();
    setState(() {
      if (trimmed.isEmpty) {
        _filteredLocations = List<CCTVLocation>.from(_cctvLocations);
      } else {
        _filteredLocations = _cctvLocations
            .where((location) => location.name.toLowerCase().contains(trimmed))
            .toList();
      }
    });
  }

  void _navigateToCCTV(BuildContext context, String name, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CCTVWebView(url: url, title: name),
      ),
    );
  }

  void _openCCTV(BuildContext context, String name, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CCTVWebView(url: url, title: name),
      ),
    );
  }
}

class _CctvCard extends StatelessWidget {
  const _CctvCard({required this.location, required this.onTap});

  final CCTVLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xffe5e7eb)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x09000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: _buildPreviewImage(),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff1f2a44),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Tap untuk streaming langsung',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: const Color(0xff6b7280),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xffeff6ff),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill_rounded,
                            color: const Color(0xff45557B), size: 16.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Lihat CCTV',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff45557B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage() {
    final assetName = location.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    final assetPath = 'assets/images/$assetName.jpg';

    return Image.asset(
      assetPath,
      width: 70.w,
      height: 70.w,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: 70.w,
          height: 70.w,
          color: const Color(0xffe5e7eb),
          child: Icon(Icons.videocam_rounded,
              color: const Color(0xff9ca3af), size: 24.sp),
        );
      },
    );
  }
}
