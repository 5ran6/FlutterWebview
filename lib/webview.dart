import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payza/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

void main() => runApp(MaterialApp(home: WebViewExample()));

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

WebViewController controllerGlobal;

Future<bool> _exitApp(BuildContext context) async {
  if (await controllerGlobal.canGoBack()) {
    print("onwill goback");
    controllerGlobal.goBack();
  } else {
    Scaffold.of(context).showSnackBar(
      const SnackBar(content: Text("No back history item")),
    );
    return Future.value(false);
  }
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = false;

  Future initState() {
    super.initState();
    _routeCheckerToHome();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit PayPaddi?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  WebViewController _webViewController;

  Future<void> _routeCheckerToHome() async {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    //Check then Navigate to Onboarding
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      if (!prefs.containsKey('firstTime')) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => OnBoardingPage()));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark),
    );

    /// Reloads the current URL.
    /// Reloads the current URL.
    Future<void> reload() {
//       WebViewPlatformController _webViewPlatformController;
      print('Reloading...');
      return _webViewController.reload();
    }

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: new RefreshIndicator(
          onRefresh: () => reload(),
          child: Scaffold(
            body: Stack(
              children: [
                WebView(
//                  initialUrl: 'https://paypaddi.com/login.php',
                  initialUrl: 'https://www.firmlife.com.ng/login',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
//                    _webViewController = webViewController;
                  },
                  // TODO(iskakaushik): Remove this when collection literals makes it to stable.
                  // ignore: prefer_collection_literals
                  javascriptChannels: <JavascriptChannel>[
                    _toasterJavascriptChannel(context),
                  ].toSet(),
                  navigationDelegate: (NavigationRequest request) {
                    if (request.url.startsWith('https://www.youtube.com/')) {
                      print('blocking navigation to $request}');
                      return NavigationDecision.prevent;
                    }
                    setState(() {
                      isLoading = true;
                    });

                    print('allowing navigation to $request');
                    return NavigationDecision.navigate;
                  },

                  onPageStarted: (String url) {
                    setState(() {
                      isLoading = false;
                    });

                    print('Page started loading: $url');
                  },
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                  },

                  gestureNavigationEnabled: true,
                ),
                Center(
                  child: Opacity(
                    opacity: isLoading ? 1.0 : 0,
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
//            return FloatingActionButton(
//              backgroundColor: Colors.red[700],
//              onPressed: () async {
//                final String url = await controller.data.currentUrl();
//                Scaffold.of(context).showSnackBar(
//                  SnackBar(content: Text('')),
//                );
//              },
//              child: const Icon(Icons.favorite),
//            );
          }
          return Container();
        });
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final Future<WebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
            onSelected: (MenuOptions value) {
              switch (value) {
                case MenuOptions.showUserAgent:
                  _onShowUserAgent(controller.data, context);
                  break;
                case MenuOptions.listCookies:
                  _onListCookies(controller.data, context);
                  break;
                case MenuOptions.clearCookies:
                  _onClearCookies(context);
                  break;
                case MenuOptions.addToCache:
                  _onAddToCache(controller.data, context);
                  break;
                case MenuOptions.listCache:
                  _onListCache(controller.data, context);
                  break;
                case MenuOptions.clearCache:
                  _onClearCache(controller.data, context);
                  break;
                case MenuOptions.navigationDelegate:
                  _onNavigationDelegateExample(controller.data, context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
//            PopupMenuItem<MenuOptions>(
//              value: MenuOptions.showUserAgent,
//              child: const Text('Show user agent'),
//              enabled: controller.hasData,
//            ),
                  const PopupMenuItem<MenuOptions>(
                    value: MenuOptions.listCookies,
                    child: Text('List cookies'),
                  ),
                  const PopupMenuItem<MenuOptions>(
                    value: MenuOptions.clearCookies,
                    child: Text('Clear cookies'),
                  ),
                  const PopupMenuItem<MenuOptions>(
                    value: MenuOptions.addToCache,
                    child: Text('Add to cache'),
                  ),
                  const PopupMenuItem<MenuOptions>(
                    value: MenuOptions.listCache,
                    child: Text('List cache'),
                  ),
                  const PopupMenuItem<MenuOptions>(
                    value: MenuOptions.clearCache,
                    child: Text('Clear cache'),
                  ),
//            const PopupMenuItem<MenuOptions>(
//              value: MenuOptions.navigationDelegate,
//             // child: Text('Navigation Delegate example'),
//            ),
//          ],
                ]);
      },
    );
  }

  void _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    await controller.evaluateJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
        await controller.evaluateJavascript('document.cookie');
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared."),
    ));
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
        cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
//            IconButton(
//              icon: const Icon(Icons.arrow_back_ios),
//              onPressed: !webViewReady
//                  ? null
//                  : () async {
//                if (await controller.canGoBack()) {
//                  await controller.goBack();
//                } else {
//                  Scaffold.of(context).showSnackBar(
//                    const SnackBar(content: Text("No back history item")),
//                  );
//                  return;
//                }
//              },
//            ),
//            IconButton(
//              icon: const Icon(Icons.arrow_forward_ios),
//              onPressed: !webViewReady
//                  ? null
//                  : () async {
//                if (await controller.canGoForward()) {
//                  await controller.goForward();
//                } else {
//                  Scaffold.of(context).showSnackBar(
//                    const SnackBar(
//                        content: Text("No forward history item")),
//                  );
//                  return;
//                }
//              },
//            ),
//            IconButton(
//              icon: const Icon(Icons.replay),
//              onPressed: !webViewReady
//                  ? null
//                  : () {
//                controller.reload();
//              },
//            ),
          ],
        );
      },
    );
  }
}
