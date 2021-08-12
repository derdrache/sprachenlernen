import 'package:flutter/material.dart';



class MyWindowsAudioplayer extends StatefulWidget {
  final String audioName;
  final String audioPath;

  const MyWindowsAudioplayer(this.audioName, this.audioPath);
  MyWindowsAudioplayerState createState() => MyWindowsAudioplayerState();
}

class MyWindowsAudioplayerState extends State<MyWindowsAudioplayer> {

  Widget build(BuildContext context) {
    var titleBackgroundColor = Theme.of(context).accentColor;
    var playerBackgroundColor = Theme.of(context).accentColor;


    return Container(
        decoration: BoxDecoration(
          color: titleBackgroundColor,
          border: Border(
                top: BorderSide(
                  width: 1,
                  color: Colors.black
                ),
                bottom: BorderSide(
                  width: 1,
                  color: Colors.black
                )
          )
        ),
    );
  }
}