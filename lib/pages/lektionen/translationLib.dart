import 'dart:convert';
import "dart:async";
import 'package:web_scraper/web_scraper.dart';
import 'package:flutter/services.dart' show rootBundle;


Future<String> loadAsset(String path) async {
  return await rootBundle.loadString(path);
}
var _sprachenDict = {
  "deutsch": "de", "spanisch": "es", "persisch": "fa", "bulgarisch": "bg",
  "chinesisch":"zh","daenisch": "da", "englisch": "en", "finnisch":"fi", "franzoesisch":"fr",
  "griechisch":"el","italienisch":"it","kroatisch":"hr", "latein":"la",
  "niederlaendisch": "nl", "norwegisch": "nb", "polnisch":"pl",
  "portugiesisch": "pt", "rumaenisch":"ro", "russisch": "ru", "schwedisch": "sv",
  "slowakisch": "sk", "slowenisch":"sl", "tschechisch":"cs", "tuerkisch":"tr",
  "ungarisch": "hu", "arabisch": "ar"
};

String deleteChar(str){
  List<String> strArr = str.split("");
  String newStr = "";
  List bannedChar = [" ", ".", ":", "«", "»", ",", "¡", "!", "?", "¿"];

  for (var i = 0; i<strArr.length; i++){
    if (!bannedChar.contains(strArr[i])){
      newStr = newStr + strArr[i];
    }
  }

  return newStr;
}

List deleteEmptySpace(arr){
  List newArr = [];
  for(var i = 0; i < arr.length; i++){
    if(arr[i] !=""){
      newArr.add(arr[i]);
    }
  }

  return newArr;
}

Future translateByPons(text,textSprache, zielSprache) async {
  List<String> resultList = [];

  final webScraper = WebScraper('https://de.pons.com');
  if (await webScraper.loadWebPage(
      '/%C3%BCbersetzung/$textSprache-$zielSprache/$text')) {
    var suche = webScraper.getElement("dl.dl-horizontal", []);

    for (var i = 0; i < suche.length; i++) {
      List sucheFormate = deleteEmptySpace(suche[i]["title"].
                          replaceAll("\n", "").split("  "));

      if (sucheFormate.length > 0){
        String sucheQuelle = sucheFormate[0].split("(")[0];
        String sucheZiel = sucheFormate.length == 2? sucheFormate[1].split("(")[0]: "";
        sucheZiel = sucheZiel.split(" ")[0];

        if (textSprache == "arabisch" || textSprache == "persisch") {
            var puffer = sucheQuelle;
            sucheQuelle = sucheZiel;
            sucheZiel = puffer;
        }

        if (sucheQuelle.split(" ").length <= 2){
          resultList.add(sucheZiel);
        }

      }
    }


    return resultList;
  }
}

Future translateByLangenscheidt (text, textSprache, zielSprache) async{
  List<String> resultList = [];

  try{
    final webScraper = WebScraper('https://de.langenscheidt.com');
    if (await webScraper.loadWebPage('/$textSprache-$zielSprache/$text')) {

      var suche =  webScraper.getElement("div.summary-inner > a",[]);
      resultList = suche.length > 0 ? suche[0]["title"].split(",") : [];

      for (var i=0; i<resultList.length;i++){
        resultList[i] = deleteChar(resultList[i]);
      }
    }

    return resultList;

  } catch(e){
    return null;
  }



}

Future translateByGlosbe(text, textSprache, zielSprache) async{
  final webScraper = WebScraper('https://de.glosbe.com');
  List<String> result = [];
  List<String> resultBackup = [];

  zielSprache = _sprachenDict[zielSprache];
  textSprache = _sprachenDict[textSprache];

  try{
    if (await webScraper.loadWebPage('/$textSprache/$zielSprache/$text') ) {
      var suche = webScraper.getElement("h3.translation > span",[]);


      for(var i = 0; i < suche.length; i++){
        result.add(suche[i]["title"].replaceAll("\n", ""));
      }

      if(result.length == 0){
        var sucheQuelle = webScraper.getElement("div#tmem_first_examples> div > "
            "div.tmem__item > div.pr-2 > strong",[]);
        var sucheTarget = webScraper.getElement("div#tmem_first_examples> div > "
            "div.tmem__item> div.relative > div > strong",[]);

        int suchIndex = sucheTarget.length < sucheQuelle.length ? sucheTarget.length : sucheQuelle.length;
        int ergebnisseBegrenzen = 4;

        for(var i=0; i<suchIndex; i++){
          resultBackup.add(sucheTarget[i]["title"]);

          if (sucheQuelle[i]["title"] == text && ergebnisseBegrenzen > 0){
            result.add(sucheTarget[i]["title"]);
            ergebnisseBegrenzen = ergebnisseBegrenzen -1;
          }
        }
      }

      if(result.length == 0){
        var begrenzung = resultBackup.length > 5? 5: resultBackup.length;

        result = resultBackup.sublist(0,begrenzung);
      }
    }
    return result;
  } catch(e){
    return null;
  }


}

Future getDictionaryData(textSprache, zielSprache) async{
  List data;

  data = jsonDecode(await loadAsset("assets/dictionary/$textSprache-$zielSprache.JSON"));


  return data;
}

Future openDictonary(text, textSprache, zielSprache) async{
  List result = [];
  List dictData;
  List reverseList = ["tuerkisch", "englisch", "spanisch", "tuerkisch", "russisch"];
  bool reverse = reverseList.contains(textSprache);

  if(reverse) {
    dictData = await getDictionaryData(zielSprache, textSprache);
  } else {
    dictData = await getDictionaryData(textSprache, zielSprache);
  }

  dictData.forEach((entry){
    var source = entry["source"];
    var target = entry["target"];

    if(reverse && target[0]==text.toLowerCase()){
      result.add(source[0]);
    } else if (!reverse && source[0]==text.toLowerCase()){
      result.add(target[0]);
    }

  });

  return result;
}

Future translateAllToOne(text, textSprache, zielSprache) async{
  List resultList = [];
  text = deleteChar(text);
  bool textIsNumber = double.tryParse(text) != null;

  if (!textIsNumber){
    //var listLangenscheidt = await translateByLangenscheidt(text, textSprache, zielSprache);
    var listGlosbe = await translateByGlosbe(text, textSprache, zielSprache);
    var openDict = await openDictonary(text, textSprache, zielSprache);

    if (listGlosbe == null){
      return null;
    } else{
      resultList = openDict + listGlosbe;

      if (resultList.length == 0){
        resultList = listGlosbe;
      }

      resultList = resultList.toSet().toList();

      return resultList;
    }
  } else{
    return resultList;
  }



}

