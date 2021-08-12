import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'open_leasson.dart';
import '../../DB/leasson/leassonsbox_notifier.dart';
import '../../DB/user_setting/user_settings_notifier.dart';
import 'add_Lesson_page.dart';
import '../../helper_functions.dart';
import 'translationLib.dart';


class MeineLektionen extends StatelessWidget {
  Widget build(BuildContext context) {
    var _leassonBox = Provider.of<LeassonsBox>(context);
    Map<dynamic, dynamic> allBoxItems = _leassonBox.item.toMap();
    var _userBox = Provider.of<UserSettingsBox>(context);
    _userBox.firstUserLogin();


    Widget showAllLeassons() {
      List<Widget> leassonList() {
        List<Widget> list = [SizedBox(height: 10)];
        List<Widget> listRow = [];
        int index = 0;

        allBoxItems.forEach((DBIndex, value) {
          listRow.add(SizedBox(width: 10));
          listRow.add(_LeassonContainer(value.name, DBIndex));


          if(index != 0 && index % 2 == 1){
            list.add(Row(children:listRow));
            list.add(SizedBox(height: 10));

            listRow = [];
          }

          index = index +1;
        });

        list.add(Row(children:listRow));

        return list;
      }

      return Column(
        children: leassonList(),
      );
    }


    return ListView(children: [
        showAllLeassons(),
      ])
    ;
  }
}

class _LeassonContainer extends StatelessWidget{
  _LeassonContainer(this.name, this.index);
  var name;
  var index;

  _cutNameLength(name){
    if(name.length > 25){
      name = name.substring(0,25);
      name = name + "...";
    }

    return name;
  }

  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: (){
          openNewPageWindow(context, OpenLeassons(index));
        },
        child:Container(
            padding: EdgeInsets.all(10),
            height: 160,
            width: MediaQuery.of(context).size.width /2 -15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
                children: [
                  Row(
                      children: [
                        LeassonLoadingStatus(index),
                        Spacer(),
                        _LeassonSettingPopup(index)
                      ]
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        _cutNameLength(name),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      )
                  ),
                ])

        )
    );
  }
}

class LeassonLoadingStatus extends StatefulWidget {
  _LeassonLoadingStatusState createState() => _LeassonLoadingStatusState();
  LeassonLoadingStatus(this.index);

  var index;
}

class _LeassonLoadingStatusState extends State<LeassonLoadingStatus> {

  Widget build(BuildContext context) {
    var _leassonBox = Provider.of<LeassonsBox>(context);
    var _userBox = Provider.of<UserSettingsBox>(context);
    int loadingNumber = _leassonBox.get(widget.index).loading;

    Future searchSaveTranslationSelection(index)async{
      var leasson = _leassonBox.get(index);
      List inhaltArr = leasson.inhalt;
      var textSprache = leasson.sprache;

      for(var i =0; i< inhaltArr.length; i++){
        var text = inhaltArr[i];
        String zielSprache = _userBox.getUserData();
        int loadingNumber = (i * 100 / inhaltArr.length).round();

        var translationSelection = await translateAllToOne(text, textSprache, zielSprache);

        if (translationSelection == null){
          _leassonBox.changeLoading(index, -1);
          return;
        }

        _leassonBox.changeInhaltChooseTranslate(index, i, translationSelection.join(";"));
        _leassonBox.changeLoading(index, loadingNumber);
      }
      _leassonBox.changeLoading(index, 100);
    }


    if (loadingNumber >= 0) {
      return Container(
          padding: EdgeInsets.only(left: 5),
          child: loadingNumber == 100 ?
          Icon(Icons.done) :
          Text("$loadingNumber %")
      );
    } else {
      return IconButton(
        padding: EdgeInsets.only(left: 5),
        icon: Icon(Icons.sync_problem),
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) =>AlertDialog(
                title: Text("Neu laden"),
                content: Text("Aufgrund vom fehlendem Internet konnten die "
                    "Übersetzungsvorschläge nicht gelaen werden. "
                    "Nochmal versuchen?"),
                actions: [
                  TextButton(
                    child: Text("Ja"),
                    onPressed: () {
                      _leassonBox.changeLoading(widget.index, 0);
                      searchSaveTranslationSelection(widget.index);
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text("Nein"),
                    onPressed: () => Navigator.pop(context)
                  ),
                ],
              )
          );
        },
      );
    }
  }

}

class _LeassonSettingPopup extends StatelessWidget{
  _LeassonSettingPopup(this.index);
  var index;

  Widget build(BuildContext context) {
    var _leassonBox = Provider.of<LeassonsBox>(context);
    var _userSettingsBox = Provider.of<UserSettingsBox>(context);


    Future<void> deleteFile(filePath) async {
      var file = File(filePath);

      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Error in getting access to the file.
      }
    }

    void _leassonDelete(index) {
      var audioPath = _leassonBox.get(index).audioPath;

      if (audioPath != null){
        deleteFile(audioPath);
      }

      _leassonBox.remove(index);
    }

    Future searchSaveTranslationSelection(index)async{
      //doppelte Function, siehe add_Leasson_page

      var leasson = _leassonBox.get(index);
      var leassonInhaltList = leasson.inhalt;
      var leassonSprache = leasson.sprache;


      for(var i =0; i< leassonInhaltList.length; i++){
        var text = leassonInhaltList[i];
        String zielSprache = _userSettingsBox.getUserData();
        int loading = (i * 100 / leassonInhaltList.length).round();

        var translationSelection = await translateAllToOne(text, leassonSprache, zielSprache);
        if (translationSelection == null){
          _leassonBox.changeLoading(index, -1);
          return;
        }

        _leassonBox.changeInhaltChooseTranslate(index, i, translationSelection.join(";"));
        _leassonBox.changeLoading(index, loading);
      }
      _leassonBox.changeLoading(index, 100);
    }


    return PopupMenuButton<int>(
      icon: Icon(Icons.settings),
      itemBuilder: (context) => [
        PopupMenuItem(
            value: 1,
            child: Text("bearbeiten")
        ),
        PopupMenuItem(
            value: 2,
            child: Text("aktualisieren")
        ),
        PopupMenuItem(
            value: 3,
            child: Text("entfernen")
        ),
      ],
      onSelected: (value){
        if(value == 1){
          openNewPageWindow(
              context,
              AddLessonPage(index:index)
          );
        } else if (value == 2){
          searchSaveTranslationSelection(index);
        } else if (value == 3){
          _leassonDelete(index);
        }
      },
    );
  }
}