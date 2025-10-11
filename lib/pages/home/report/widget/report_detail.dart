import 'dart:io';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:JIR/pages/home/report/widget/url_network.dart';
import 'package:JIR/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> report;
  const ReportDetailPage({super.key, required this.report});
  get binding => null;

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd MMM yyyy • HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(12.w),
        child: InteractiveViewer(
          child: imageUrl.startsWith('http')
              ? Image.network(
                  Uri.encodeFull(imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black,
                    child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white)),
                  ),
                )
              : (() {
                  try {
                    final f = File(imageUrl);
                    if (f.existsSync()) {
                      return Image.file(f, fit: BoxFit.contain);
                    } else {
                      return Image.network(
                        Uri.encodeFull(imageUrl),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black,
                          child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white)),
                        ),
                      );
                    }
                  } catch (_) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white)),
                    );
                  }
                }()),
        ),
      ),
    );
  }

  String _resolveDocumentSource(Map<String, dynamic> report) {
    final candidates = [
      report['documentPath'],
      report['document_path'],
      report['documentUrl'],
      report['document_url'],
    ];
    for (final candidate in candidates) {
      final value = (candidate ?? '').toString();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  Future<void> _openDocumentAttachment(String source) async {
    if (source.isEmpty) return;

    if (source.startsWith('http')) {
      final uri = Uri.tryParse(source);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Lampiran', 'Tidak dapat membuka tautan dokumen',
            snackPosition: SnackPosition.BOTTOM);
      }
      return;
    }

    final file = resolveLocalFile(source);
    if (file != null) {
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        Get.snackbar('Lampiran', 'Gagal membuka dokumen: ${result.message}',
            snackPosition: SnackPosition.BOTTOM);
      }
      return;
    }

    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    Get.snackbar('Lampiran', 'Lampiran dokumen tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM);
  }

  String _documentDisplayName(String source) {
    try {
      return p.basename(source);
    } catch (_) {
      return 'Lampiran';
    }
  }

  Map<String, String> _documentMetadata(String source) {
    final displayName = _documentDisplayName(source);
    final extension =
        p.extension(displayName).replaceFirst('.', '').toUpperCase();

    final file = resolveLocalFile(source);
    if (file != null) {
      final size = file.lengthSync();
      return {
        'type': extension.isNotEmpty ? extension : 'FILE',
        'subtitle': '${_formatFileSize(size)} • Tersimpan di perangkat',
      };
    }

    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return {
        'type': extension.isNotEmpty ? extension : 'URL',
        'subtitle': 'Tautan eksternal • Ketuk untuk membuka',
      };
    }

    return {
      'type': extension.isNotEmpty ? extension : 'FILE',
      'subtitle': 'Ketuk untuk membuka lampiran',
    };
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    final precision = value >= 100
        ? 0
        : value >= 10
            ? 1
            : 2;
    return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
  }

  Widget _buildField(String label, String value,
      {IconData icon = Icons.info_outline}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: const Color(0xFF45557B), size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF45557B))),
                SizedBox(height: 4.h),
                Text(value.isNotEmpty ? value : '-',
                    style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({double height = 16, double radius = 8, double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final imageUrl =
        (report['imagePath'] ?? report['image_path'] ?? '').toString();
    final title = (report['type'] ?? 'Laporan').toString();
    final desc = (report['description'] ?? '').toString();
    final name = (report['contactName'] ?? 'Anonim').toString();
    final phone = (report['contactPhone'] ?? '').toString();
    final date = (report['dateTime'] ?? '').toString();
    final address = (report['address'] ?? '').toString();
    final status = (report['status'] ?? 'Menunggu').toString();
    final severity = (report['severity'] ?? '').toString();
    final severityLabel = ReportController.severityLabelForType(
        (report['type'] ?? '').toString());
    final customTypeDetail =
        (report['customTypeDetail'] ?? report['custom_type_detail'] ?? '')
            .toString();
    final documentSource = _resolveDocumentSource(report);
    final hasDocument = documentSource.isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      appBar: AppBar(
        title: Text('Detail Laporan',
            style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp)),
        backgroundColor: const Color(0xFF45557B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 84.h),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 18.r,
                            offset: Offset(0, 10.h),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: [
                          if (isLoading)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.white),
                              ),
                            )
                          else if (imageUrl.isNotEmpty)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: GestureDetector(
                                onTap: () => _showFullImage(context, imageUrl),
                                child: buildReportImage(imageUrl,
                                    height: 200, fit: BoxFit.cover),
                              ),
                            )
                          else
                            Container(
                              height: 180.h,
                              color: const Color(0xFFEEF2FF),
                              child: Center(
                                child: Text('Tidak ada foto',
                                    style: GoogleFonts.inter(
                                        color: const Color(0xFF7C86A8))),
                              ),
                            ),
                          Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: isLoading
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _shimmerBox(height: 18, width: 120),
                                            const SizedBox(height: 6),
                                            _shimmerBox(height: 12, width: 80),
                                          ],
                                        )
                                      : Text(
                                          title,
                                          style: GoogleFonts.inter(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87),
                                        ),
                                ),
                                isLoading
                                    ? _shimmerBox(
                                        height: 28, width: 80, radius: 20)
                                    : Chip(
                                        label: Text(status,
                                            style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 12.sp)),
                                        backgroundColor: status
                                                .toLowerCase()
                                                .contains('diterima')
                                            ? const Color(0xFF66BB6A)
                                            : status
                                                    .toLowerCase()
                                                    .contains('ditolak')
                                                ? const Color(0xFF45557B)
                                                : const Color(0xFFFFA726),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6.r,
                              offset: Offset(0, 2.h)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: isLoading
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            _shimmerBox(
                                                height: 36,
                                                width: double.infinity),
                                          ])
                                    : _buildField(
                                        'Waktu Kejadian', _formatDate(date),
                                        icon: Icons.access_time),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: isLoading
                                    ? _shimmerBox(
                                        height: 36, width: double.infinity)
                                    : _buildField(severityLabel,
                                        severity.isNotEmpty ? severity : '-',
                                        icon: Icons.warning_amber_outlined),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          isLoading
                              ? _shimmerBox(height: 48, width: double.infinity)
                              : _buildField('Alamat / Lokasi',
                                  address.isNotEmpty ? address : '-',
                                  icon: Icons.location_on_outlined),
                          SizedBox(height: 12.h),
                          isLoading
                              ? _shimmerBox(height: 48, width: double.infinity)
                              : _buildField('Pelapor',
                                  name + (phone.isNotEmpty ? ' • $phone' : ''),
                                  icon: Icons.person_outline),
                          SizedBox(height: 12.h),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Deskripsi',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF45557B))),
                                SizedBox(height: 6.h),
                                isLoading
                                    ? _shimmerBox(
                                        height: 80, width: double.infinity)
                                    : Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(14.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.02),
                                              blurRadius: 10.r,
                                              offset: Offset(0, 4.h),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                            desc.isNotEmpty ? desc : '-',
                                            style: GoogleFonts.inter(
                                                fontSize: 13.sp,
                                                height: 1.5,
                                                color:
                                                    const Color(0xFF2F3653))),
                                      ),
                              ]),
                          SizedBox(height: 12.h),
                          if (!isLoading && customTypeDetail.isNotEmpty)
                            _buildField('Detail Laporan', customTypeDetail,
                                icon: Icons.notes_outlined),
                          if (isLoading && hasDocument)
                            _shimmerBox(height: 48, width: double.infinity),
                          if (!isLoading && hasDocument)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lampiran Dokumen',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF45557B))),
                                SizedBox(height: 6.h),
                                Builder(builder: (context) {
                                  final metadata =
                                      _documentMetadata(documentSource);
                                  return Ink(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F7FB),
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 0.6),
                                    ),
                                    child: InkWell(
                                      onTap: () => _openDocumentAttachment(
                                          documentSource),
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.w, vertical: 14.h),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                                Icons
                                                    .insert_drive_file_outlined,
                                                color: const Color(0xFF45557B),
                                                size: 26.sp),
                                            SizedBox(width: 14.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _documentDisplayName(
                                                        documentSource),
                                                    style: GoogleFonts.inter(
                                                        fontSize: 13.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color(
                                                            0xFF1F2347)),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    metadata['subtitle'] ??
                                                        'Ketuk untuk membuka',
                                                    style: GoogleFonts.inter(
                                                        fontSize: 11.5.sp,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Icon(Icons.open_in_new_rounded,
                                                color: const Color(0xFF45557B),
                                                size: 20.sp),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: imageUrl.isNotEmpty && !isLoading
                          ? () => _showFullImage(context, imageUrl)
                          : null,
                      icon: Icon(Icons.fullscreen,
                          color: const Color(0xFF45557B), size: 20.sp),
                      label: Text('Lihat Foto',
                          style: GoogleFonts.inter(
                              color: const Color(0xFF45557B), fontSize: 14.sp)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF45557B),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Kembali',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14.sp)),
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
}
