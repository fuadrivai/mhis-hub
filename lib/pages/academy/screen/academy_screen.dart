import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  int loadingCount = 0;
  late String accountEmail;
  bool isLoading = true;
  late final WebViewController _controller;
  late final WebViewCookieManager cookieManager = WebViewCookieManager();
  PlatformWebViewControllerCreationParams params =
      const PlatformWebViewControllerCreationParams();
  @override
  void initState() {
    clearCookies();
    Session.get("email").then((email) {
      if (email != null || email != "") {
        setState(() {
          accountEmail = email!;
          if (WebViewPlatform.instance is WebKitWebViewPlatform) {
            params = WebKitWebViewControllerCreationParams
                .fromPlatformWebViewControllerCreationParams(
              params,
            );
          } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
            params = AndroidWebViewControllerCreationParams
                .fromPlatformWebViewControllerCreationParams(
              params,
            );
          }
          final WebViewController webViewController =
              WebViewController.fromPlatformCreationParams(params)
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..clearCache()
                ..canGoBack()
                ..loadRequest(Uri.parse(
                    "http://academy.mhis.link/login-url?username=$accountEmail"))
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onProgress: (int progress) {
                      loadingCount = progress;
                    },
                    onPageStarted: (String url) =>
                        setState(() => loadingCount = 0),
                    onPageFinished: (String url) =>
                        setState(() => loadingCount = 100),
                    onHttpError: (HttpResponseError error) {},
                    onWebResourceError: (WebResourceError error) {},
                  ),
                );

          _controller = webViewController;
        });
      }
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  void clearCookies() async {
    await cookieManager.clearCookies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: (loadingCount < 100)
          ? const LoadingWidget()
          : Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: WebViewWidget(controller: _controller),
            ),
    );
  }
}
