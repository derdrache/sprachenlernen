import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LeassonsBox extends ChangeNotifier {

  Box _leassonBox = Hive.box('leassons');

  Box get item => _leassonBox;

  get(int index){
    return _leassonBox.get(index);
  }

  int lastIndex(){
    var boxMap = _leassonBox.toMap();
    int? lastIndex;

    boxMap.forEach((index, value) {
      lastIndex = index;
    });

    return lastIndex!;
  }

  void add(var item) {
    _leassonBox.add(item);
    notifyListeners();
  }


  void remove(int index) {
    _leassonBox.delete(index);
    notifyListeners();
  }

  void changeAll(index, leasson){
    var leassonDB = _leassonBox.get(index);

    leassonDB = leasson;

    leassonDB.save();
    notifyListeners();
  }


  void changeInhaltTranslate(int leassonIndex, int sentanceIndex, change){
    var leasson = _leassonBox.get(leassonIndex);
    leasson.inhaltTranslate[sentanceIndex] = change;
    leasson.save();
    notifyListeners();
  }

  void changeInhaltChooseTranslate(int leassonIndex, int sentanceIndex,  change){
    var leasson = _leassonBox.get(leassonIndex);
    leasson.inhaltChooseTranslate[sentanceIndex] = change;
    leasson.save();
    notifyListeners();
  }

  void changeLoading(int leassonIndex, change){
    var leasson = _leassonBox.get(leassonIndex);
    leasson.loading = change;

    leasson.save();
    notifyListeners();
  }


}

