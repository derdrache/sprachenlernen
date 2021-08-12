import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DB/user_setting/user_settings_notifier.dart';

class SpracheAuswahlDropdown extends StatefulWidget {
  var dropdownValueMain;

  SpracheAuswahlDropdown({this.dropdownValueMain = null});

  set dropdownValue(value) {
    dropdownValueMain = value;
  }

  get dropdownValue => dropdownValueMain;

  _SpracheAuswahlDropdownState createState() => _SpracheAuswahlDropdownState();
}

class _SpracheAuswahlDropdownState extends State<SpracheAuswahlDropdown> {

  Widget build(BuildContext context) {
    var _userSettingsBox = Provider.of<UserSettingsBox>(context);
    var _sprachenliste = [
      "deutsch", "englisch", "spanisch", "tuerkisch", "russisch", "franzoesisch"
    ];



    /*
  var _sprachenliste = [
  "portugiesisch","finnisch","niederlaendisch(dutch)","schwedisch", "polnisch",
  "italienisch",

    "chinesisch", "daenisch", "latein", "norwegisch", "persisch",
    "rumaenisch", "slowakisch", "slowenisch", "tschechisch", "ungarisch"
    "bulgarisch","kroatisch","griechisch","arabisch",




  ];

   */

    // offen: var sprachauswahl = ["japanisch",];


    List<String> removeAppLanguage(arr){
      var appLanguage = _userSettingsBox.getUserData();

      if(arr.contains(appLanguage)){
        arr.remove(appLanguage);
      }

      return arr;
    }

    String capitalize(str) {
      List strArr = str.split("");
      strArr[0] = strArr[0].toUpperCase();

      return strArr.join("");
    }

    Widget myDropdownButton(){
      if(widget.dropdownValue == null){
        _sprachenliste = removeAppLanguage(_sprachenliste);
      }

      return DropdownButton(
          underline: Container(),
          value: widget.dropdownValue,
          hint: Text("Sprachauswahl"),
          items: _sprachenliste.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Center(
                  child: Text(
                    capitalize(value),
                    style: TextStyle(fontSize: 20),
                  )),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              widget.dropdownValue = newValue;
            });
          }
      );
    }


    return Container(
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2)),
        child: myDropdownButton()
    );
  }
}
