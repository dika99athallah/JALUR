import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatHistorySheet extends StatelessWidget {
  const ChatHistorySheet({
    super.key,
    required this.rooms,
    required this.currentRoomId,
    required this.onSelectRoom,
    required this.onCreateRoom,
    required this.onDeleteRoom,
    required this.onRenameRoom,
  });

  final List<Map<String, dynamic>> rooms;
  final String? currentRoomId;
  final Future<void> Function(String roomId) onSelectRoom;
  final Future<void> Function() onCreateRoom;
  final Future<void> Function(String roomId) onDeleteRoom;
  final Future<void> Function(String roomId, String title) onRenameRoom;

  String _formatTimestamp(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final formatter = DateFormat('dd MMM HH:mm');
    return formatter.format(date);
  }

  String _roomSubtitle(Map<String, dynamic> room) {
    final List messages =
        (room['messages'] is List) ? List.from(room['messages']) : const [];
    if (messages.isEmpty) {
      return 'Belum ada percakapan';
    }
    final dynamic last = messages.last;
    if (last is Map && last['text'] != null) {
      final text = last['text'].toString().trim();
      if (text.isEmpty) {
        return 'Pesan tanpa teks';
      }
      return text.length > 60 ? '${text.substring(0, 57)}…' : text;
    }
    return 'Pesan terakhir tidak tersedia';
  }

  @override
  Widget build(BuildContext context) {
    final double targetHeight =
        rooms.isEmpty ? 180.h : math.min(360.h, 140.h + rooms.length * 72.h);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Riwayat Obrolan',
              style: GoogleFonts.lexend(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xff45557B),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: targetHeight,
              child: rooms.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada riwayat chat.\nMulai percakapan baru untuk menyimpannya di sini.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: rooms.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        final roomId = room['id']?.toString() ?? '';
                        final bool isActive = roomId == currentRoomId;
                        final subtitle = _roomSubtitle(room);
                        final updated =
                            _formatTimestamp(room['updatedAt']?.toString());

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () => onSelectRoom(roomId),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xff45557B).withOpacity(0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xff45557B)
                                      : Colors.black12,
                                  width: isActive ? 1.4 : 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18.r,
                                    backgroundColor: const Color(0xff45557B)
                                        .withOpacity(0.12),
                                    child: Icon(
                                      isActive
                                          ? Icons.chat_bubble_rounded
                                          : Icons.chat_bubble_outline_rounded,
                                      color: const Color(0xff45557B),
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          room['title']?.toString() ??
                                              'Obrolan',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xff1F2937),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          subtitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (updated.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 4.h),
                                          child: Text(
                                            updated,
                                            style: GoogleFonts.inter(
                                              fontSize: 11.sp,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                            iconSize: 20.sp,
                                            color: const Color(0xff45557B),
                                            icon: const Icon(
                                              Icons.edit_note_outlined,
                                            ),
                                            onPressed: () async {
                                              final controller =
                                                  TextEditingController(
                                                text:
                                                    room['title']?.toString() ??
                                                        'Obrolan',
                                              );
                                              final result =
                                                  await showDialog<String>(
                                                context: context,
                                                builder: (dialogContext) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Ubah Nama Obrolan'),
                                                    content: TextField(
                                                      controller: controller,
                                                      autofocus: true,
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            'Masukkan nama baru',
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    dialogContext)
                                                                .pop(),
                                                        child: Text(
                                                          'Batal',
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: const Color(
                                                                0xff45557B),
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    dialogContext)
                                                                .pop(controller
                                                                    .text),
                                                        child: Text(
                                                          'Simpan',
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: const Color(
                                                                0xff45557B),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              if (result == null ||
                                                  result.trim().isEmpty) {
                                                return;
                                              }
                                              await onRenameRoom(
                                                roomId,
                                                result,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                            iconSize: 20.sp,
                                            color: Colors.redAccent,
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                            ),
                                            onPressed: () async {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Hapus Percakapan?'),
                                                            content: Text(
                                                              'Riwayat chat pada "${room['title'] ?? 'Obrolan'}" akan dihapus permanen.',
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 13.sp,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop(
                                                                            false),
                                                                child: Text(
                                                                  'Batal',
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    color: const Color(
                                                                        0xff45557B),
                                                                  ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop(
                                                                            true),
                                                                child: Text(
                                                                  'Hapus',
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    color: Colors
                                                                        .redAccent,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ) ??
                                                      false;
                                              if (!confirmed) return;
                                              await onDeleteRoom(roomId);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add_comment_rounded, size: 18.sp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff45557B),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: onCreateRoom,
                label: Text(
                  'Mulai Obrolan Baru',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
