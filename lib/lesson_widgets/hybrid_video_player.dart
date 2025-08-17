import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HybridYouTubePlayer extends StatefulWidget {
  final String videoUrl;
  const HybridYouTubePlayer({super.key, required this.videoUrl});

  @override
  State<HybridYouTubePlayer> createState() => _HybridYouTubePlayerState();
}

class _HybridYouTubePlayerState extends State<HybridYouTubePlayer> {
  YoutubePlayerController? _ytController;
  late final WebViewController _webViewController;
  bool _useWebView = false;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      try {
        _ytController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      } catch (e) {
        _useWebView = true;
      }
    } else {
      _useWebView = true;
    }

    if (_useWebView) {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      final embedUrl = videoId != null
          ? "https://www.youtube.com/embed/$videoId"
          : "about:blank";

      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(embedUrl));
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_useWebView || _ytController == null) {
      return SizedBox(
        height: 220,
        child: WebViewWidget(controller: _webViewController),
      );
    }

    return YoutubePlayer(
      controller: _ytController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
    );
  }
}
