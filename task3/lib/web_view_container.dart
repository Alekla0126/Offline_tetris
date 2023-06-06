import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  const WebViewPage({Key? key, required this.url}) : super(key: key);
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late InAppWebViewController _webViewController;
  final ImagePicker _picker = ImagePicker();
  late XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          // Navigate back in web-view history.
          _webViewController.goBack();
          return false;
        } else {
          // Exit app.
          return true;
        }
      },
      child: Scaffold(
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: true,
              javaScriptCanOpenWindowsAutomatically: true,
              mediaPlaybackRequiresUserGesture: false,
              // Javascript is enabled.
              javaScriptEnabled: true,
            ),
            android: AndroidInAppWebViewOptions(
              useHybridComposition: true,
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            if (navigationAction.request.url!.toString().startsWith('fileUpload:')) {
              // Handle file upload action
              // await handleFileUpload();
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
          androidOnPermissionRequest:
              (InAppWebViewController controller, String origin,
              List<String> resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
        ),
      ),
    );
  }
  // In case it is needed, it is possible to pick an image.
  Future<void> handleFileUpload() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
      _webViewController.evaluateJavascript(source: 'fileUploadComplete("${pickedFile.path}");');
    }
  }
}