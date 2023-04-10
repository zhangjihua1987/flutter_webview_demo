import 'package:flutter/material.dart';
import 'package:flutter_webview_demo/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStack extends StatefulWidget {
  const WebViewStack({required this.controller, super.key});

  final WebViewController controller;

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    widget.controller
      ..setNavigationDelegate(NavigationDelegate(onPageStarted: ((url) {
        setState(() {
          loadingPercentage = 0;
        });
      }), onProgress: ((progress) {
        setState(() {
          loadingPercentage = progress;
        });
      }), onPageFinished: (url) {
        setState(() {
          loadingPercentage = 100;
        });
      }, onNavigationRequest: (navigation) {
        final host = Uri.parse(navigation.url).host;
        if (host.contains('youtube.com')) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Blocking navigation to $host')));
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      }))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('SnackBar', onMessageReceived: (message) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message.message)));
      })
      ..addJavaScriptChannel('ToSomeWeb', onMessageReceived: (message) {
        widget.controller.loadRequest(Uri.parse(message.message));
      })
      ..addJavaScriptChannel('BackToHome', onMessageReceived: (message) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: widget.controller),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100,
          )
      ],
    );
  }
}
