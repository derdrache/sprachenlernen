import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/sprache_auswahl_dropdown.dart';
import 'DB/user_setting/user_settings_notifier.dart';

class MainSettingPage extends StatelessWidget {

  Widget build(BuildContext context) {
    var _userBox = Provider.of<UserSettingsBox>(context);
    var userSprache = _userBox.getUserData();
    var sprachAuswahlDropdown = new SpracheAuswahlDropdown(dropdownValueMain: userSprache);

    return Scaffold(
        appBar: AppBar(title: Text("Einstellungen")),
        body: Column(
            children: [
              SizedBox(height: 15),
              EigeneSpracheAuswahl(sprachAuswahlDropdown),
              SizedBox(height: 15),
              EinstellungenSpeichern(sprachAuswahlDropdown, _userBox),
            ]
        )
    );
  }
}

class EigeneSpracheAuswahl extends StatelessWidget {
  const EigeneSpracheAuswahl(this.sprachAuswahlDropdown);
  final sprachAuswahlDropdown;

  Widget build(BuildContext context){
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Eigene Sprache: ",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(width: 15),
          sprachAuswahlDropdown,
        ]
    );
  }

}

class EinstellungenSpeichern extends StatelessWidget{
  const EinstellungenSpeichern(this.sprachAuswahlDropdown, this.userBox);
  final sprachAuswahlDropdown;
  final userBox;

  Widget build(BuildContext context){
    void saveAndClose(){
      if (sprachAuswahlDropdown.dropdownValue != null){
        userBox.changeUserSprache(sprachAuswahlDropdown.dropdownValue);
        Navigator.pop(context);
      }
    }

    return FloatingActionButton.extended(
        onPressed: saveAndClose,
        label: Text("speichern",
            style: TextStyle(fontSize: 20)
        )
    );
  }
}


