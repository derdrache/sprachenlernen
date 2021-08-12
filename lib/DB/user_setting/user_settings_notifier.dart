import 'package:flutter/material.dart';
import 'user_settings.model.dart';
import 'package:hive/hive.dart';


class UserSettingsBox extends ChangeNotifier{
  Box _userSettingsBox = Hive.box('UserSettings');

  Box get item => _userSettingsBox;

  String getUserData(){
    return _userSettingsBox.get(0).eigeneSprache;
  }

  void changeUserSprache(sprache){
    var user = _userSettingsBox.get(0);
    user.eigeneSprache = sprache;
    user.save();
    notifyListeners();
  }

  bool firstUserLogin(){
    if (_userSettingsBox.get(1) == null){
      var neuerUser = new UserSettings(eigeneSprache: '');
      neuerUser.eigeneSprache = "deutsch";
      _userSettingsBox.add(neuerUser);
      return true;
    }
    return false;
  }

}