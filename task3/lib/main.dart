import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_info/device_info.dart';
import 'package:app/tetris/tetris.dart';
import 'package:flutter/material.dart';
import 'web_view_container.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task 3',
      home: Scaffold(body: HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _navigationCompleter = Completer<void>();
  final Connectivity _connectivity = Connectivity();
  String _url = '';

  @override
  void initState() {
    super.initState();
    _fetchUrl();
  }

  bool _isValidUrl(String url) {
    // In case there is a space after the trim.
    if (url.trim().isEmpty || url.trim() == ' ') {
      return false;
    }
    // Check if the URL is valid by parsing it.
    Uri? uri = Uri.tryParse(url);
    // If the URL is valid and has a scheme (http/https).
    if (uri != null && uri.hasScheme) {
      return true; // Valid URL
    }
    // If the URL is valid but does not have a scheme (http/https).
    else if (uri != null && !uri.hasScheme) {
      return false; // Invalid URL
    }
    // If the URL is invalid.
    return false; // Invalid URL
  }

  _fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localUrl = prefs.getString('localUrl');
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNetworkErrorDialog();
      setState(() {
        _url = localUrl ?? '';
      });
    } else {
      try {
        final remoteConfig = FirebaseRemoteConfig.instance;
        await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 60),
          minimumFetchInterval: const Duration(seconds: 0),
        ));
        await remoteConfig.fetchAndActivate();
        String firebaseUrl = remoteConfig.getString('firebaseUrl');

        // Checking if the local URL is different from the Firebase URL
        // and updating the value.
        // if (firebaseUrl != localUrl) {
        //   print('URL has been updated');
        //   prefs.setString('localUrl', firebaseUrl);
        // }

        // Check if the fetched URL is a valid URL
        bool emulator = await checkIsEmu();
        // Print the URL, do not include in production.
        // print('Fetched URL: $firebaseUrl');
        if ((emulator == false) || _isValidUrl(firebaseUrl)) {
          setState(() {
            _url = firebaseUrl;
          });
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TetrisGamePage()),
          );
        }
      } catch (e) {
        _showNetworkErrorDialog();
      }
    }
  }

  @override
  void dispose() {
    _navigationCompleter.future
        .then((_) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const TetrisGamePage()),
            ));
    super.dispose();
  }

  _showNetworkErrorDialog() {
    showDialog(
      context: context,
      // The user cannot close the dialog.
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          // If reopen, the dialog will still be open.
          onWillPop: () async => false,
          child: const AlertDialog(
            title: Text('Network Connection Error'),
            content: Text('A network connection is required to continue.'),
            // The screen should be frozen, the should not be an option to quit.
            // actions: <Widget>[
            //   TextButton(
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //     child: const Text('OK'),
            //   ),
            // ],
          ),
        );
      },
    );
  }

  checkIsEmu() async {
    final devinfo = DeviceInfoPlugin();
    final em = await devinfo.androidInfo;
    var phoneModel = em.model;
    var buildProduct = em.product;
    var buildHardware = em.hardware;
    var result = (em.fingerprint.startsWith("generic") ||
        phoneModel.contains("google_sdk") ||
        phoneModel.contains("droid4x") ||
        phoneModel.contains("Emulator") ||
        phoneModel.contains("Android SDK built for x86") ||
        em.manufacturer.contains("Genymotion") ||
        buildHardware == "goldfish" ||
        buildHardware == "vbox86" ||
        buildProduct == "sdk" ||
        buildProduct == "google_sdk" ||
        buildProduct == "sdk_x86" ||
        buildProduct == "vbox86p" ||
        em.brand.contains('google') ||
        em.board.toLowerCase().contains("nox") ||
        em.bootloader.toLowerCase().contains("nox") ||
        buildHardware.toLowerCase().contains("nox") ||
        !em.isPhysicalDevice ||
        buildProduct.toLowerCase().contains("nox"));
    if (result) return true;
    result = result ||
        (em.brand.startsWith("generic") && em.device.startsWith("generic"));
    if (result) return true;
    result = result || ("google_sdk" == buildProduct);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_url.isEmpty) {
      // Show a loading or error widget when URL is empty.
      // While the app is charging, then renders the website or stub.
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return WebViewPage(url: _url);
    }
  }
}
