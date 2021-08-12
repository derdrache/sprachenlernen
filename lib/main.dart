import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';

import 'DB/leasson/leasson.model.dart';
import 'DB/leasson/leassonsbox_notifier.dart';
import 'DB/user_setting/user_settings.model.dart';
import 'DB/user_setting/user_settings_notifier.dart';
import 'pages/lektionen/leasson_page.dart';
import 'pages/sprachspiele_page.dart';
import 'pages/vokabel_page.dart';
import 'pages/lektionen/add_Lesson_page.dart';

import 'widgets/mainAppBar.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized(); //weil Hive nach beenden noch offen ist??

  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(LeassonAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  await Hive.openBox('leassons');
  await Hive.openBox('UserSettings');

  SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  int _tabIndex = 0;



  @override //nicht zwingend notwendig
  Widget build(BuildContext context){

    void _updateTabIndex(int index) {
      setState(() => _tabIndex = index);
    }

    Widget tabFloatingbutton(newWindow, buttonText){
      var containerBackgroundcolor = Colors.red;

      return OpenContainer(
        closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28))
        ),
        closedColor: Colors.transparent,
        openBuilder: (BuildContext c, VoidCallback action) => newWindow,
        closedBuilder: (BuildContext c, VoidCallback action) =>
            FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              backgroundColor: containerBackgroundcolor,
              onPressed: () => action(),
            ),
      );
    }

    Widget addTabBottomFloatingbuttons(){
      Widget? returnButton;

      if (_tabIndex==0){
        returnButton = tabFloatingbutton(AddLessonPage(),"Lektion");
      } else if (_tabIndex == 1){
        returnButton = tabFloatingbutton(null,"Vokabeln");
      } else if (_tabIndex ==2){
        returnButton = tabFloatingbutton(null,"Sprachspiele");
      }

      return returnButton!;
    }


    return MultiProvider(
        providers: [
          ChangeNotifierProvider<LeassonsBox>(
              create: (context) => LeassonsBox()),
          ChangeNotifierProvider<UserSettingsBox>(
              create: (context) => UserSettingsBox())
        ],
        child:MaterialApp(
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.blueGrey,
              primaryColor: Colors.green,
              accentColor: Colors.green,
              //primarySwatch: Colors.green,
            ),
            home: AudioServiceWidget(child:DefaultTabController(
              length: 1,
              child: Scaffold(
                appBar: MainAppBar(update: _updateTabIndex),//
                body: TabBarView(
                    children: [
                      MeineLektionen(),
                      //VokabelPage(),
                      //PlaylistPage()
                    ]
                ),
                floatingActionButton: addTabBottomFloatingbuttons(),
              ),
            ))
        )
    );
  }
}