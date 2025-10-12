import 'dart:io';

import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ReportPage extends StatelessWidget {
  final ReportController controller = Get.find<ReportController>();
  ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: _buildHeader(context),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(100.h),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
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
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.sp,
                    color: const Color(0xff1f2a44),
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lapor',
                      style: GoogleFonts.lexend(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff45557B),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Lampirkan bukti lalu isi detail laporan',
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
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final imageFile = controller.imageFile.value;
      final File? documentFile = controller.documentFile.value;
      final documentName =
          documentFile != null ? p.basename(documentFile.path) : null;
      final documentSize = documentFile != null
          ? _formatFileSize(documentFile.lengthSync())
          : null;

      return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lampirkan bukti sebelum mengisi detail laporan.',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2D5A),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Sekurangnya satu foto wajib diunggah. Anda juga dapat menambahkan dokumen pendukung (PDF, Word, Excel, dsb).',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF4C5870),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text('Foto Bukti',
                style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF45557B))),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (imageFile == null)
                    Container(
                      height: 180.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F9),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12.r)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_outlined,
                              size: 42.sp, color: const Color(0xFF8792B3)),
                          SizedBox(height: 8.h),
                          Text('Belum ada foto dipilih',
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF6B728E))),
                        ],
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12.r)),
                      child: Image.file(
                        imageFile,
                        width: double.infinity,
                        height: 220.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: Text(imageFile == null
                                ? 'Pilih Foto'
                                : 'Ganti Foto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF45557B),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        if (imageFile != null) ...[
                          SizedBox(width: 12.w),
                          IconButton(
                            tooltip: 'Hapus foto',
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0x1AF87171),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            onPressed: () => controller.imageFile.value = null,
                            icon: Icon(Icons.delete_outline,
                                color: const Color(0xFFEF5350), size: 22.sp),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text('Dokumen Pendukung',
                style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF45557B))),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: controller.pickDocument,
                    borderRadius: BorderRadius.circular(10.r),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FB),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FB),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              documentFile == null
                                  ? Icons.upload_file_outlined
                                  : Icons.insert_drive_file_rounded,
                              color: const Color(0xFF45557B),
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  documentName ?? 'Tambahkan dokumen pendukung',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2D5A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  documentFile == null
                                      ? 'PDF, Word, Excel, atau TXT (opsional)'
                                      : '${documentSize ?? ''} • Ketuk untuk ganti',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5.sp,
                                    color: const Color(0xFF6B728E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (documentFile != null) ...[
                            IconButton(
                              tooltip: 'Hapus dokumen',
                              onPressed: controller.removeDocument,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints.tightFor(
                                  width: 32.w, height: 32.w),
                              icon: Icon(Icons.close_rounded,
                                  color: const Color(0xFFEF5350), size: 18.sp),
                            ),
                            SizedBox(width: 4.w),
                          ],
                          Icon(Icons.chevron_right_rounded,
                              color: const Color(0xFF45557B), size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToReportForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF45557B),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Lanjut Isi Detail Laporan',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    });
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

  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Pilih Sumber Gambar',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Ambil dari Galeri', style: GoogleFonts.inter()),
              onTap: () => _handleImageSelection(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text('Gunakan Kamera', style: GoogleFonts.inter()),
              onTap: () => _handleImageSelection(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  void _handleImageSelection(ImageSource source) {
    Get.back();
    controller.pickImage(source);
  }

  void _navigateToReportForm() {
    if (controller.imageFile.value == null) {
      Get.snackbar('Lampiran', 'Pilih minimal satu foto bukti terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.toNamed(AppRoutes.reportForm);
  }
}
