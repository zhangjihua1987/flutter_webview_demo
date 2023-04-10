import 'package:flutter/material.dart';
import 'package:flutter_webview_demo/src/menu.dart';
import 'package:flutter_webview_demo/src/navigation_controll.dart';
import 'package:flutter_webview_demo/src/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter demo'),
      ),
      body: Center(
        child: Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WebViewApp()), (route) => false);
                },
                child: const Text('to web view'))
          ],
        ),
      ),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(Uri.parse('http://localhost:5173/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Webview'),
        actions: [
          NavigationControls(
            controller: controller,
          ),
          Menu(controller: controller)
        ],
      ),
      body: WebViewStack(controller: controller),
    );
  }
}
