import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'panel/page_portrait.dart';
import 'material/audios.dart';
import 'generated/l10n.dart';
import 'gamer/keyboard.dart';
import 'gamer/gamer.dart';


final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class TetrisGamePage extends StatelessWidget {
  const TetrisGamePage({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tetris',
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      navigatorObservers: [routeObserver],
      supportedLocales: S.delegate.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Sound(child: Game(child: KeyboardController(child: _HomePage()))),
      ),
    );
  }
}

const SCREEN_BORDER_WIDTH = 3.0;
const BACKGROUND_COLOR = Color(0xffefcc19);

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only Android/iOS support landscape mode.
    bool land = MediaQuery.of(context).orientation == Orientation.landscape;
    return land ? PageLand() : PagePortrait();
  }
}