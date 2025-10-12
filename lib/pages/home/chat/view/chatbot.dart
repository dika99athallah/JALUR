import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/home/chat/view/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotOpeningPage extends StatefulWidget {
  const ChatbotOpeningPage({super.key});

  @override
  State<ChatbotOpeningPage> createState() => _ChatbotOpeningPageState();
}

class _ChatbotOpeningPageState extends State<ChatbotOpeningPage> {
  bool _assetsPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_assetsPrecached) return;
    _assetsPrecached = true;
    precacheImage(const AssetImage('assets/images/bg1.png'), context);
    precacheImage(const AssetImage('assets/images/bg2.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xff45557B),
            size: 20.sp,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 340.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 530,
                  maxHeight: 400,
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg1.png'),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        "Hallo\nAku Suki",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2A3342),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Image.asset(
                        'assets/images/suki.png',
                        width: 195.w,
                        height: 270.h,
                      ),
                    ],
                  ),
                  Text(
                    "Asisten anda untuk \nmendeteksi banjir \ndan kerumunan",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      color: const Color(0xff2A3342),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(
                        () => const ChatView(),
                        routeName: AppRoutes.chatbottext,
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 300),
                        preventDuplicates: false,
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color(0xffE45835);
                        }
                        return const Color(0xff45557B);
                      }),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
                      ),
                    ),
                    child: Text(
                      "Ayo Memulai Chat",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  FloatingActionButton(
                    onPressed: () {
                      Get.to(
                        () => const ChatView(),
                        routeName: AppRoutes.chatbottext,
                        arguments: const {'autoMic': true},
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 220),
                        preventDuplicates: false,
                      );
                    },
                    backgroundColor: const Color(0xffEAEFF3),
                    child: Icon(
                      Icons.mic,
                      size: 30.sp,
                      color: Colors.red,
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
}
