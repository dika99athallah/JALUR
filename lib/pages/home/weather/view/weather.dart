import 'package:JIR/pages/home/weather/controller/weather_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:JIR/pages/home/weather/widget/diagonal_container.dart';
import 'package:get/get.dart';
import 'package:JIR/utils/greeting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:JIR/pages/home/weather/widget/weather_helper.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration period;
  const Shimmer(
      {super.key,
      required this.child,
      this.period = const Duration(milliseconds: 1200)});
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final double slide = (_ctrl.value * 2) - 1;
        final gradient = LinearGradient(
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.1, 0.5, 0.9],
          begin: Alignment(-1.0 - slide, 0),
          end: Alignment(1.0 - slide, 0),
        );
        return ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class WeatherPage extends StatelessWidget {
  WeatherPage({super.key});
  final WeatherController controller = Get.put(WeatherController());

  String _hourLabelFor(DateTime dt) {
    final now = DateTime.now();
    final diff =
        dt.difference(DateTime(now.year, now.month, now.day, now.hour)).inHours;
    if (diff == 0) return 'Sekarang';
    if (diff < 0) return '${-diff} jam lalu';
    return '$diff jam lagi';
  }

  int _floorHourEpochSeconds(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, dt.hour)
            .millisecondsSinceEpoch ~/
        1000;
  }

  Widget _buildHourlyShimmerList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(width: 12.w),
      itemBuilder: (_, __) => Shimmer(
        child: Container(
          width: 90.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryShimmerList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(width: 12.w),
      itemBuilder: (_, __) => Shimmer(
        child: Container(
          width: 90.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 260.h,
            child: Stack(
              children: [
                const DiagonalContainer(),
                Positioned.fill(
                  child: ClipPath(
                    clipper: DiagonalClipper(),
                    child: Shimmer(
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(Get.context!).padding.top + 16.w,
                    left: 16.w,
                    right: 16.w,
                    bottom: 35.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Shimmer(
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Shimmer(
                              child: Container(
                                height: 18.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Shimmer(
                        child: Container(
                          width: 140.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Shimmer(
                              child: Container(
                                height: 150.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Shimmer(
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Shimmer(
                                  child: Container(
                                    height: 28.h,
                                    width: 120.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Shimmer(
                                  child: Container(
                                    height: 24.h,
                                    width: 160.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Shimmer(
                        child: Container(
                          width: 160.w,
                          height: 22.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 110.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, __) => Shimmer(
                        child: Container(
                          width: 84.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemCount: 6,
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Shimmer(
                        child: Container(
                          width: 150.w,
                          height: 22.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 110.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, __) => Shimmer(
                        child: Container(
                          width: 84.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemCount: 6,
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Shimmer(
                      child: Container(
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    height: 110.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, __) => Shimmer(
                        child: Container(
                          width: 230.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemCount: 4,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      body: Obx(() {
        if (controller.loading.value) {
          return _buildShimmerSkeleton();
        }
        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }
        final greeting = greetingForNow();
        final username = controller.username.value.isNotEmpty
            ? controller.username.value
            : 'Pengguna';
        final location = controller.location.value;
        final tempRaw = controller.temperature.value;
        final parsedTemp = double.tryParse(tempRaw.replaceAll(',', '.'));
        final mainTempDisplay = parsedTemp != null
            ? '${parsedTemp.toStringAsFixed(1)}°C'
            : (tempRaw.isNotEmpty ? tempRaw : '-');
        final rangeDisplay = controller.temperatureRange.value;
        final description = controller.description.value;
        final weatherIcon = controller.weatherIcon.value;
        final background = controller.backgroundImage.value;
        final today = DateTime.now();
        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des'
        ];
        final days = List<DateTime>.generate(
            7,
            (i) => DateTime(today.year, today.month, today.day)
                .add(Duration(days: i)));
        final now = DateTime.now();
        final nowHourEpoch = _floorHourEpochSeconds(now);
        return SafeArea(
          child: ColoredBox(
            color: const Color(0xfff5f7fb),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x11000000),
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18.sp, color: const Color(0xff1f2a44)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lexend(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff45557B),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '$greeting $username',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: const Color(0xff45557B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _buildTodayOverviewCard(
                      weatherIcon: weatherIcon,
                      background: background,
                      temperature: mainTempDisplay,
                      description: description,
                      range: rangeDisplay,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  _buildSectionHeader('Prediksi Cuaca'),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 128.h,
                    child: Obx(() {
                      if (controller.hourlyLoading.value) {
                        return _buildHourlyShimmerList();
                      }
                      final list = controller.hourlyWindow;
                      if (list.isEmpty) {
                        return _buildMinimalEmptyList(
                          iconPath:
                              'assets/images/Cuaca Smart City Icon-02.png',
                          message: 'Data belum tersedia',
                        );
                      }
                      final itemCount = list.length.clamp(0, 12);
                      return ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          final dt = DateTime.fromMillisecondsSinceEpoch(
                              (item['dt'] as int) * 1000);
                          final label = _hourLabelFor(dt);
                          final temp = (item['temp'] is num)
                              ? '${(item['temp'] as num).toDouble().toStringAsFixed(1)}°C'
                              : item['temp'].toString();
                          final desc = item['description'] as String? ?? '';
                          final rawDesc =
                              item['rawDescription'] as String? ?? desc;
                          final conditionType =
                              item['conditionType'] as String?;
                          final iconPath = WeatherHelper.getImageForWeather(
                            rawDesc,
                            conditionType: conditionType,
                          );
                          final itemEpoch = (item['dt'] as int);
                          final isActive = itemEpoch == nowHourEpoch;
                          final activeTemp = parsedTemp != null
                              ? '${parsedTemp.toStringAsFixed(1)}°C'
                              : temp;
                          return _ForecastChip(
                            label: label,
                            value: isActive ? activeTemp : temp,
                            iconPath: iconPath,
                            highlight: isActive,
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(width: 14.w),
                        itemCount: itemCount,
                      );
                    }),
                  ),
                  SizedBox(height: 32.h),
                  _buildSectionHeader('Cuaca Lampau'),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 136.h,
                    child: Obx(() {
                      if (controller.historyLoading.value) {
                        return _buildHistoryShimmerList();
                      }
                      final list = controller.history;
                      if (list.isEmpty) {
                        return _buildMinimalEmptyList(
                          iconPath:
                              'assets/images/Cuaca Smart City Icon-05.png',
                          message: 'Belum ada rekam cuaca',
                        );
                      }
                      final itemCount = list.length.clamp(0, 12);
                      return ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          final dt = DateTime.fromMillisecondsSinceEpoch(
                              (item['dt'] as int) * 1000);
                          final label = _hourLabelFor(dt);
                          final temp = (item['temp'] is num)
                              ? '${(item['temp'] as num).toDouble().toStringAsFixed(1)}°C'
                              : item['temp'].toString();
                          final desc = item['description'] as String? ?? '';
                          final rawDesc =
                              item['rawDescription'] as String? ?? desc;
                          final conditionType =
                              item['conditionType'] as String?;
                          final iconPath = WeatherHelper.getImageForWeather(
                            rawDesc,
                            conditionType: conditionType,
                          );
                          return _HistoryCard(
                            label: label,
                            value: temp,
                            iconPath: iconPath,
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(width: 14.w),
                        itemCount: itemCount,
                      );
                    }),
                  ),
                  SizedBox(height: 32.h),
                  _buildSectionHeader('Hari ini'),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: days.map((d) {
                        final isToday = d.day == today.day &&
                            d.month == today.month &&
                            d.year == today.year;
                        final monthShort = monthNames[d.month - 1];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _DailyChip(
                            label: '${d.day} $monthShort ${d.year}',
                            highlight: isToday,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTodayOverviewCard({
    required String weatherIcon,
    required String background,
    required String temperature,
    required String description,
    required String range,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 60, 75, 112), Color(0xff45557B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220d3b66),
            blurRadius: 22,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (background.isNotEmpty)
            Positioned(
              right: 0.w,
              bottom: -20.h,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  background,
                  width: 220.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          temperature,
                          style: GoogleFonts.lexend(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          range,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Image.asset(
                    weatherIcon,
                    width: 110.w,
                    height: 110.w,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xff45557B),
              ),
            ),
          ),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xff45557B),
              borderRadius: BorderRadius.circular(12.r),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMinimalEmptyList({
    required String iconPath,
    required String message,
  }) {
    return Center(
      child: Container(
        width: 220.w,
        margin: EdgeInsets.symmetric(vertical: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xffe5e7eb)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 48.w,
              height: 48.w,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: const Color(0xff6b7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastChip extends StatelessWidget {
  const _ForecastChip({
    required this.label,
    required this.value,
    required this.iconPath,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String iconPath;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final Color bg = highlight ? const Color(0xff45557B) : Colors.white;
    final Color fg = highlight ? Colors.white : const Color(0xff45557B);

    return Container(
      width: 120.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: highlight ? const Color(0xff45557B) : const Color(0xffd1d5db),
        ),
        boxShadow: highlight
            ? const [
                BoxShadow(
                  color: Color(0x1A1d4ed8),
                  blurRadius: 20,
                  offset: Offset(0, 12),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
          SizedBox(height: 8.h),
          Image.asset(
            iconPath,
            width: 38.w,
            height: 38.w,
            color: highlight ? Colors.white : null,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.label,
    required this.value,
    required this.iconPath,
  });

  final String label;
  final String value;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xffe5e7eb)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xff6b7280),
            ),
          ),
          SizedBox(height: 10.h),
          Image.asset(
            iconPath,
            width: 36.w,
            height: 36.w,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff45557B),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChip extends StatelessWidget {
  const _DailyChip({required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final Color bg = highlight ? const Color(0xff45557B) : Colors.white;
    final Color fg = highlight ? Colors.white : const Color(0xff45557B);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: highlight ? const Color(0xff45557B) : const Color(0xffe5e7eb),
        ),
        boxShadow: highlight
            ? const [
                BoxShadow(
                  color: Color(0x1A1d4ed8),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
          Icon(Icons.calendar_today_rounded, size: 16.sp, color: fg),
        ],
      ),
    );
  }
}
