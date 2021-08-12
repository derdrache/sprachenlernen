import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../DB/leasson/leassonsbox_notifier.dart';
import '../../audioplayer.dart';
import '../../audioplayer_windwos.dart';
import 'leassonTranslateWidget.dart';
import '../../widgets/besideAppBar.dart';


class OpenLeassons extends StatelessWidget{
  final int index;

  const OpenLeassons(this.index);




  Widget build(BuildContext context) {
    var _leassonBox = Provider.of<LeassonsBox>(context);
    var leassonData = _leassonBox.item.get(index);
    bool includeAudioData = leassonData.audioName != null;


    Widget _addAudioplayer(){
      Widget? audioplayer;

      if(Platform.isAndroid){
        audioplayer = MyAudioplayer(leassonData.audioName,leassonData.audioPath);
      } else if(Platform.isWindows){
        audioplayer =  MyWindowsAudioplayer(leassonData.audioName,leassonData.audioPath);
      }

      return audioplayer!;
    }

    return new Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: BesideAppBar(title:leassonData.name),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          includeAudioData ? _addAudioplayer() : SizedBox(),
          Expanded(child: LeassonTranslateBox(index))
        ]
      )
    );
  }
}