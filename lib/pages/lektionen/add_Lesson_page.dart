import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../DB/leasson/leasson.model.dart';
import '../../DB/leasson/leassonsbox_notifier.dart';
import '../../DB/user_setting/user_settings_notifier.dart';
import '../../widgets/sprache_auswahl_dropdown.dart';
import '../../widgets/besideAppBar.dart';
import 'translationLib.dart';

var newLeasson;

class _AudiodateiAnzeigen extends StatefulWidget {
  _AudiodateiAnzeigenState createState() => _AudiodateiAnzeigenState();
}

class _AudiodateiAnzeigenState extends State<_AudiodateiAnzeigen>{
  bool addedAudioData = false;

/*
  void initState() {
    super.initState();
    if (newLeasson.audioName != null){
      addedAudioData = true;
    }
  }

 */

  Widget build(BuildContext context) {
    var screenWidth = MediaQuery. of(context). size. width;

    if (newLeasson.audioName != ""){
      addedAudioData = true;
    }

    void changeAudioDateiAnzeige(){
      setState((){
        addedAudioData = false;
      });
    }

    Future askPermission() async{
      var storagePermissionStatus = await Permission.storage.status;

      if (!storagePermissionStatus.isGranted) {
        await Permission.storage.request();
      }
    }

    Future chooseFileSmartphone() async {
      FilePickerResult? myFile = await FilePicker.platform.pickFiles(
          type: FileType.audio
      );

      newLeasson.audioName = myFile!.names[0];
      newLeasson.audioPath = myFile.paths[0];
    }

    Future chooseFileWindows() async{
      final file = OpenFilePicker()
        ..filterSpecification = {
          'Sound File (*.mp3)': '*.mp3',
        }
        ..defaultFilterIndex = 0
        ..defaultExtension = 'mp3'
        ..title = 'Select a document';

      final result = file.getFile();
      if (result != null) {
        var filePath = result.path;
        var fileName = filePath.split('\\').last;

        newLeasson.audioPath = filePath;
        newLeasson.audioName = fileName;
      }
    }

    Future _getFileSavePath() async {
      Directory test = await getApplicationDocumentsDirectory();

      Directory directory = test;
      String path = directory.path;

      if(Platform.isAndroid){
        return path;
      } else if (Platform.isWindows){
        path = path + '\\sprachlern_app';
        bool folderExists = await Directory(path).exists();

        if(folderExists){
          return path;
        } else{
          new Directory(path).create();
        }
      }

    }

    Future copyAndSetAudioFile() async{
      String path = await _getFileSavePath();

      File audioFile = File(newLeasson.audioPath);
      await audioFile.copy('$path/${newLeasson.audioName}');

      newLeasson.audioPath = '$path/${newLeasson.audioName}';

      setState(() {
        addedAudioData = true;
      });
    }

    void getAudioFile() async{



      if (Platform.isAndroid){
        await askPermission();
        await chooseFileSmartphone();
      } else if (Platform.isWindows){
        await chooseFileWindows();
      }


      if (newLeasson.audioName != null){
        await copyAndSetAudioFile();
      }
    }

    void deleteLeassonAudiodata() {
      newLeasson.audioPath = null;
      newLeasson.audioName = null;
    }

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

    Widget showAudioName(){
      return Container(
          width: 400,
          margin:EdgeInsets.only(left:screenWidth*0.15, right:screenWidth*0.15),
          padding: EdgeInsets.only(left: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12)
          ),
          child: Row(
              children:[
                Expanded(
                    child: Center(
                        child: Text(
                          newLeasson.audioName ?? "",
                          style: TextStyle(
                              fontSize: 18
                          ),
                        )
                    )
                ),
                FloatingActionButton(
                    heroTag: null,
                    mini:true,
                    child: Icon(Icons.close),
                    onPressed: () {
                      changeAudioDateiAnzeige();
                      deleteFile(newLeasson.audioPath);
                      deleteLeassonAudiodata();

                    }
                 )
              ]
          )
      );
    }

    if (addedAudioData){
      return showAudioName();
    } else{
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).accentColor
        ),
        onPressed: () {
          getAudioFile();
        },
        child: Text("Audio Datei hinzufügen")
      );
    }
  }

}

class AddLessonPage extends StatelessWidget {
  AddLessonPage({this.index = null});

  var index;
  var sprachAuswahlDropdown = new SpracheAuswahlDropdown();
  bool addedAudioData = false;
  final titelController = TextEditingController();
  final inhaltController = TextEditingController();


  Widget build(BuildContext context) {
    var _leassonBox = Provider.of<LeassonsBox>(context);
    var _userSettingsBox = Provider.of<UserSettingsBox>(context);

    Future searchSaveTranslationSelection(inhaltArr, textSprache)async{
      var lastIndex = _leassonBox.lastIndex();

      for(var i =0; i< inhaltArr.length; i++){
        var text = inhaltArr[i];
        String zielSprache = _userSettingsBox.getUserData();
        int loading = (i * 100 / inhaltArr.length).round();

        var translationSelection = await translateAllToOne(text, textSprache, zielSprache);
        if (translationSelection == null){
          _leassonBox.changeLoading(lastIndex, -1);
          return;
        }

        _leassonBox.changeInhaltChooseTranslate(lastIndex, i, translationSelection.join(";"));
        _leassonBox.changeLoading(lastIndex, loading);
      }
      _leassonBox.changeLoading(lastIndex, 100);
    }

    leassonInhaltFormate(){
      var inhalt = inhaltController.text.replaceAll("\n", " ");
      List inhaltArr = [];

      if(sprachAuswahlDropdown.dropdownValue == "chinesisch"){
        inhaltArr = inhalt.split("");
      } else{
        inhaltArr = inhalt.split(" ");
      }


      return inhaltArr;
    }

    void clearAllInput(){
      sprachAuswahlDropdown = new SpracheAuswahlDropdown();
      titelController.text = "";
      inhaltController.text = "";
    }

    void saveAndClose(){
      newLeasson.name = titelController.text;
      newLeasson.inhalt = leassonInhaltFormate();
      newLeasson.inhaltOriginal = inhaltController.text;
      newLeasson.inhaltTranslate = List.filled(newLeasson.inhalt.length, "");
      newLeasson.inhaltChooseTranslate = List.filled(newLeasson.inhalt.length, "");
      newLeasson.sprache = sprachAuswahlDropdown.dropdownValue;
      newLeasson.loading = 0;

      if (newLeasson.name == "" || newLeasson.inhalt.length == 0 || newLeasson.sprache == null){
        showDialog(context: context, builder: (context){
          return AlertDialog(content:Text("Bitte alle Felder ausfüllen"));
        });
      } else{
         if(index == null){
           _leassonBox.add(newLeasson);
           searchSaveTranslationSelection(newLeasson.inhalt, newLeasson.sprache);
         } else{
           _leassonBox.changeAll(index, newLeasson);
         }
        clearAllInput();
        Navigator.pop(context);
      }
    }

    Widget textTitleEingabe(){
      return Container(
          width: 400,
          padding: EdgeInsets.only(left:10,right:10),
          child: TextFormField(
              controller: titelController,
              decoration:
              InputDecoration(hintText: "Titel hinzufügen")
          )
      );
    }

    Widget textInhaltEingabe(){
      return Container(
          width: 400,
          padding: EdgeInsets.only(left:10,right:10),
          child: TextFormField(
            controller: inhaltController,
            decoration: InputDecoration(hintText: "Inhalt einfügen"),
            minLines: 5,
            maxLines: null,
          )
      );
    }

    void loadLeasson(){
      newLeasson = _leassonBox.item.toMap()[index];
      sprachAuswahlDropdown = new SpracheAuswahlDropdown(
          dropdownValueMain: newLeasson.sprache);
      titelController.text = newLeasson.name;
      inhaltController.text = newLeasson.inhaltOriginal;
    }

    void createOrLoadLeasson(){
      if(index == null){
        newLeasson = new Leasson();
      } else {
        loadLeasson();
      }
    }


    createOrLoadLeasson();

    return new Scaffold(
        appBar: BesideAppBar(title: "Lektion Hinzufügen"),
        body: Center(
            child:SingleChildScrollView(
              child: Column(
                children: [
                  sprachAuswahlDropdown,
                  SizedBox(height:15),
                  textTitleEingabe(),
                  SizedBox(height:15),
                  textInhaltEingabe(),
                  SizedBox(height:15),
                  _AudiodateiAnzeigen(),
                  SizedBox(height:15),
                  FloatingActionButton.extended(
                      onPressed: saveAndClose,
                      label:  Text(index == null ? "Hinzufügen" : "Speichern")
            ),
                  SizedBox(height:15),
                ],
              ),
            )
        )
    );
  }
}
