import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascriptChannel,
  listCookies,
  clearCookies,
  addCookie,
  setCookie,
  removeCookie,
}

class Menu extends StatefulWidget {
  final WebViewController controller;

  const Menu({required this.controller, super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final cookieManager = WebViewCookieManager();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuOptions>(
        onSelected: (value) async {
          switch (value) {
            case _MenuOptions.navigationDelegate:
              await widget.controller
                  .loadRequest(Uri.parse('https://youtube.com'));
              break;
            case _MenuOptions.userAgent:
              final ua = await widget.controller
                  .runJavaScriptReturningResult('navigator.userAgent');
              if (!mounted) {
                return;
              }
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('$ua')));
              break;
            case _MenuOptions.javascriptChannel:
              await widget.controller.runJavaScript('''
var req = new XMLHttpRequest();
req.open('GET', "https://api.ipify.org/?format=json");
req.onload = function() {
  if (req.status == 200) {
    let response = JSON.parse(req.responseText);
    SnackBar.postMessage("IP Address: " + response.ip);
  } else {
    SnackBar.postMessage("Error: " + req.status);
  }
}
req.send();
''');
              break;
            case _MenuOptions.clearCookies:
              _onClearCookies();
              break;
            case _MenuOptions.listCookies:
              _onListCookies();
              break;
            case _MenuOptions.addCookie:
              _onAddCookie();
              break;
            case _MenuOptions.setCookie:
              _onSetCookie();
              break;
            case _MenuOptions.removeCookie:
              _onRemoveCookie();
              break;
            default:
              throw Exception('error navigation option of $value');
          }
        },
        itemBuilder: (context) => [
              const PopupMenuItem<_MenuOptions>(
                  value: _MenuOptions.navigationDelegate,
                  child: Text('Navigate to YouTube')),
              const PopupMenuItem<_MenuOptions>(
                  value: _MenuOptions.userAgent,
                  child: Text('Show user-agent')),
              const PopupMenuItem<_MenuOptions>(
                  value: _MenuOptions.javascriptChannel,
                  child: Text('Lookup IP Address')),
              const PopupMenuItem<_MenuOptions>(
                value: _MenuOptions.clearCookies,
                child: Text('Clear cookies'),
              ),
              const PopupMenuItem<_MenuOptions>(
                value: _MenuOptions.listCookies,
                child: Text('List cookies'),
              ),
              const PopupMenuItem<_MenuOptions>(
                value: _MenuOptions.addCookie,
                child: Text('Add cookie'),
              ),
              const PopupMenuItem<_MenuOptions>(
                value: _MenuOptions.setCookie,
                child: Text('Set cookie'),
              ),
              const PopupMenuItem<_MenuOptions>(
                value: _MenuOptions.removeCookie,
                child: Text('Remove cookie'),
              ),
            ]);
  }

  Future<void> _onListCookies() async {
    final String cookies = await widget.controller
        .runJavaScriptReturningResult('document.cookie') as String;
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(cookies)));
  }

  Future<void> _onClearCookies() async {
    final hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There were no cookies to clear';
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onAddCookie() async {
    await widget.controller.runJavaScript('''var date = new Date();
  date.setTime(date.getTime()+(30*24*60*60*1000));
  document.cookie = "FirstName=John; expires=" + date.toGMTString();''');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie added.'),
      ),
    );
  }

  Future<void> _onSetCookie() async {
    await cookieManager.setCookie(
        const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie is set.'),
      ),
    );
  }

  Future<void> _onRemoveCookie() async {
    await widget.controller.runJavaScript(
        'document.cookie="FirstName=John; expires=Thu, 01 Jan 1970 00:00:00 UTC" ');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie removed.'),
      ),
    );
  }
}
