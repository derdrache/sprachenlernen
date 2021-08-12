import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import '../main_setting_page.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  MainAppBar({required this.update});

  final Size preferredSize = Size.fromHeight(90);
  final ValueChanged<int> update;


  void _tabSelected(int index){
    update(index);
  }

  Widget mainSetting(){
    return OpenContainer(
      closedColor: Colors.green,
      openBuilder: (context, action)=> MainSettingPage(),
      closedBuilder: (context, action) =>
          IconButton(
            icon: Icon(Icons.settings_sharp),
            onPressed: () => action()
          )
    );
  }


  Widget build(BuildContext context){
    return AppBar(
      primary: false,
      title: Text("Sprachenlern App"),
      actions:[
        IconButton(icon: Icon(Icons.local_florist_outlined), onPressed: null),
        Align(child: Text("0")),
        SizedBox(width: 16),//Streak
        mainSetting(), //Settings
      ],
      bottom: TabBar(
        labelStyle: TextStyle(fontSize: 16.0, fontFamily: 'Family Name'),
        tabs: [
          Tab(text: "Lektionen"),
          //Tab(text: "Vokabeln"),
          //Tab(text: "Sprachspiele")
        ],
        onTap: _tabSelected,
      ),
    );
  }
}