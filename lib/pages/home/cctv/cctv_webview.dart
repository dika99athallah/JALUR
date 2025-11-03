import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';

class CCTVWebView extends StatefulWidget {
  final String url;
  final String? title; 

  const CCTVWebView({super.key, required this.url, this.title});

  @override
  _CCTVWebViewState createState() => _CCTVWebViewState();
}

class _CCTVWebViewState extends State<CCTVWebView> {
  late final WebViewController _controller;
  VideoPlayerController? _videoController;
  bool _useLocalVideo = false;

  @override
  void initState() {
    super.initState();
    final Map<String, String> assetMap = {
      'DPR': 'assets/videos/cctv_dpr.mp4',
      'Bundaran HI': 'assets/videos/cctv_bundaran_hi.mp4',
      'Monas': 'assets/videos/cctv_monas.mp4',
      'Patung Kuda': 'assets/videos/cctv_patung_kuda.mp4',
    };

    final title = widget.title?.trim();
    if (title != null && assetMap.containsKey(title)) {
      _useLocalVideo = true;
      _videoController = VideoPlayerController.asset(assetMap[title]!)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _videoController?.setLooping(true);
          _videoController?.play();
        });
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live CCTV",
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            )),
        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: const Color(0xFF45557B),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _useLocalVideo
          ? SafeArea(
              child: Center(
                child: _videoController != null &&
                        _videoController!.value.isInitialized
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width,
                          maxHeight: MediaQuery.of(context).size.height,
                        ),
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }

  @override
  void dispose() {
    try {
      _videoController?.pause();
      _videoController?.dispose();
    } catch (_) {}
    super.dispose();
  }
}
