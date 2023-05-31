import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  final Connectivity _connectivity = Connectivity();
  final flutterWebviewPlugin = FlutterWebviewPlugin();
  String _url = 'https://alekla0126.github.io/tetris/#/';

  @override
  void initState() {
    super.initState();
    _fetchUrl();
  }

  _fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localUrl = prefs.getString('localUrl');

    if (localUrl != null && localUrl.isNotEmpty) {
      _url = localUrl;
    }

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
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ));
        String firebaseUrl = remoteConfig.getString('firebaseUrl');
        if (firebaseUrl.isNotEmpty) {
          prefs.setString('localUrl', firebaseUrl);
          setState(() {
            _url = firebaseUrl;
          });
        }
      } catch (e) {
        print('Error fetching remote config: $e');
      }
    }
  }

  _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Network Connection Error'),
          content: Text('A network connection is required to continue.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_url.isEmpty) {
      // Show a loading or error widget when URL is empty
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return WebviewScaffold(
        url: _url,
        appBar: AppBar(
          title: Text('Webview'),
        ),
      );
    }
  }
}