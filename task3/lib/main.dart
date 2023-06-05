import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tetris/penaltyShootout/penaltyGame.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'web_view_container.dart';
import 'tetris/tetris.dart';
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

        bool emulator = await checkIsEmu();
        // Should not be printed in production.
        // print('Fetched URL: $firebaseUrl');

        if ((firebaseUrl != '') || (emulator == false)) {
          setState(() {
            _url = firebaseUrl;
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Choose Game'),
              content: Text('Which game would you like to play?'),
              actions: [
                TextButton(
                  child: Text('Tetris'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const TetrisGamePage()),
                    );
                  },
                ),
                TextButton(
                  child: Text('Penalty shooter'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => GameWidget(game: PenaltyGame())),
                    );
                  },
                ),
              ],
            ),
          );
        }
      } catch (e) {
        _showNetworkErrorDialog();
      }
    }
  }

  @override
  void dispose() {
    _navigationCompleter.future.then((_) => Navigator.of(context).pushReplacement(
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
            // The screen should be frozen.
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
    var phoneModel = em.model; var buildProduct = em.product; var buildHardware = em.hardware;
    var result = (em.fingerprint.startsWith("generic") || phoneModel.contains("google_sdk") || phoneModel.contains("droid4x") || phoneModel.contains("Emulator") || phoneModel.contains("Android SDK built for x86") || em.manufacturer.contains("Genymotion") || buildHardware == "goldfish" ||
        buildHardware == "vbox86" || buildProduct == "sdk" || buildProduct == "google_sdk" || buildProduct == "sdk_x86" || buildProduct == "vbox86p" || em.brand.contains('google')|| em.board.toLowerCase().contains("nox") || em.bootloader.toLowerCase().contains("nox") || buildHardware.toLowerCase().contains("nox") || ! em.isPhysicalDevice ||
        buildProduct.toLowerCase().contains("nox"));
    if (result) return true; result = result ||
        (em.brand.startsWith("generic") && em.device.startsWith("generic")); if (result) return true;
    result = result || ("google_sdk" == buildProduct);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_url.isEmpty) {
      // Show a loading or error widget when URL is empty.
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return WebViewPage(url: _url);
    }
  }
}