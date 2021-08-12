import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../DB/leasson/leassonsbox_notifier.dart';


class LeassonTranslateBox extends StatefulWidget{
  final int index;

  const LeassonTranslateBox(this.index);

  _LeassonTranslateBoxState createState() => _LeassonTranslateBoxState();
}

class _LeassonTranslateBoxState extends State<LeassonTranslateBox>{
  double textSize = 18;
  var rowHeightPuffer = 20.0;
  int _pageNr = 0;
  int maxPages = 1;
  double mainBoxPadding = 10;

  
  Widget build(BuildContext context) {
    var _leassonBox = Provider.of<LeassonsBox>(context);
    var _leassonBoxItems = _leassonBox.item.get(widget.index);
    String leassonSprache = _leassonBoxItems.sprache;
    var mainContainerBackgroundColor = Theme.of(context).accentColor;
    int audioDataHeight = _leassonBoxItems.audioName != null ? 55 : 0;
    var screenWidth =  MediaQuery.of(context). size.width*0.96 - (mainBoxPadding*2);
    var screenHeight = MediaQuery.of(context). size.height -(mainBoxPadding*2) -
                        audioDataHeight - 160;
    int _wordIndexCounter = 0;

    TextPainter getTextSize(text){
      final style = TextStyle(fontSize: textSize);

      TextPainter textPainter = TextPainter()
        ..text = TextSpan(text: text, style: style)
        ..textDirection = TextDirection.ltr
        ..layout(minWidth: 0, maxWidth: double.infinity);

      return textPainter;
    }

    List<PopupMenuItem> _showPopupMenu(index){
      List leassonTranslateList = _leassonBoxItems.inhaltChooseTranslate;

      var wordTranslateList = leassonTranslateList[index].split(";");
      List<PopupMenuItem> menuItems = [];

      for(var i = 0; i < wordTranslateList.length; i++) {
        menuItems.add(
            PopupMenuItem(
              value: wordTranslateList[i],
              child: Text(wordTranslateList[i]),
            )
        );
      }

      menuItems.add(
          PopupMenuItem(
            value: "<Eingabe>",
            child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Eigene"
                ),
                onSubmitted: (text) {
                  _leassonBox.changeInhaltTranslate(widget.index,index, text);
                  Navigator.pop(context);
                }
            ),
          )
      );

      return menuItems;
    }

    Widget wordBox(index, inhaltText, translateText) {
      return PopupMenuButton(
        child: Column(
            children: [
              Text(
                inhaltText,
                style: TextStyle(fontSize: textSize),
              ),
              Container(
                  height: 40,
                  child: Text(translateText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textSize
                    )
                  )
              ),
              Container(
                height: rowHeightPuffer -15,
              )
            ]
        ),
        itemBuilder: (context) {
          return _showPopupMenu(index);
        },
        onSelected: (value){
          _leassonBox.changeInhaltTranslate(widget.index,index, value);
        },
      );
    }

    Widget createInhaltRow(textList, translateTextList){
      List<Widget> row = [];

      for (var i = 0; i < textList.length; i++){
        row.add(wordBox(_wordIndexCounter, textList[i], translateTextList[i]));
        row.add(SizedBox(width: 5));
        _wordIndexCounter = _wordIndexCounter +1;
      }

      if (leassonSprache != "arabisch" && leassonSprache != "persisch"){
        return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:row //reverse =>
        );
      } else{
        return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:row.reversed.toList()
        );
      }

    }

    List checkListWidth(listA, listB){
      List<String> newList = [];

      for(var i = 0; i < listA.length; i++){
        var itemListAWidth = getTextSize(listA[i]).width;
        var itemListBWidth = getTextSize(listB[i]).width;
        newList.add(itemListAWidth > itemListBWidth ? listA[i]: listB[i]);
      }

      return newList;
    }

    List<Widget> createTextRowList(){
      List<Widget> rowList = [];
      List leassonInhalt =  _leassonBoxItems.inhalt;
      List leassonTranslate = _leassonBoxItems.inhaltTranslate;

      int rowCutIndex = 0;

      for(var i = 0; i <= leassonInhalt.length; i++) {
        List inhaltArr = leassonInhalt.sublist(rowCutIndex, (i));
        List translationArr = leassonTranslate.sublist(rowCutIndex, (i));
        var rowCalcArr = checkListWidth(inhaltArr, translationArr).join(" ");
        var rowWidth = getTextSize(rowCalcArr).width;

        if (rowWidth >= screenWidth) {
          List addInhaltArr = leassonInhalt.sublist(rowCutIndex, (i-1));
          List addTranslationArr = leassonTranslate.sublist(rowCutIndex, (i-1));

          rowList.add(createInhaltRow(addInhaltArr, addTranslationArr));
          rowCutIndex = i-1;
        }
      }

      List inhaltArr = leassonInhalt.sublist(rowCutIndex);
      List translationArr = leassonTranslate.sublist(rowCutIndex);

      rowList.add(createInhaltRow(inhaltArr, translationArr));

      return rowList;
    }

    List<Widget> createTextPageList(textRow){
      List<Widget> pageBlockList = [];
      var leassonTextHeight = getTextSize(_leassonBoxItems.inhalt[0]).height;
      var translationTextHeight = getTextSize(_leassonBoxItems.inhaltTranslate[0]).height;
      var pageHeight = leassonTextHeight + translationTextHeight + rowHeightPuffer;
      int listCutIndex = 0;
      double rowCounter = 0;

      for(var i = 0; i <= textRow.length; i++){
        rowCounter = rowCounter + 1;

        if(pageHeight * rowCounter >= screenHeight){
          pageBlockList.add(Column(children: textRow.sublist(listCutIndex,i)));

          listCutIndex = i;
          i = i-1;
          rowCounter = 0;
        } else if(i == textRow.length){
          pageBlockList.add(Column(children: textRow.sublist(listCutIndex,i)));
        }
      }

      return pageBlockList;
    }

    List<Widget> createPageBlocks(){
      List<Widget> textRowList = createTextRowList();
      List<Widget> textPageList = createTextPageList(textRowList);

      setState(() {
        maxPages = textPageList.length - 1;
      });

      return textPageList;
    }


    Widget pageControllButton(bool forward, int nextPage){
      return Container(
          margin: EdgeInsets.only(top:10),
          child: FloatingActionButton(
            heroTag: null,
              onPressed: (){
                setState(() {
                  _pageNr = nextPage;
                });
              },
              child: Icon(forward ? Icons.arrow_forward: Icons.arrow_back)
          )
      );
    }

    Widget pagePorgressSlider(){
      return Expanded(
          child: SliderTheme(
              data: SliderThemeData(
                disabledActiveTrackColor: Colors.red,
                thumbColor: Colors.white,
              ),
              child: Slider(
                min: 0,
                max: maxPages.toDouble(),
                value: _pageNr.toDouble(),
                onChanged: null,
              )
          )
      );
    }

    Widget pageControlBar(){
      return Row(
        children: [
          Opacity(
            opacity: _pageNr ==0 ? 0: 1,
            child: _pageNr ==0 ? FloatingActionButton(heroTag: null,onPressed: null) :
                    pageControllButton(false, _pageNr - 1)
          ),
          pagePorgressSlider(),
          Opacity(
            opacity: _pageNr == maxPages ? 0: 1,
            child: _pageNr == maxPages ? FloatingActionButton(heroTag: null,onPressed: null) :
                   pageControllButton(true, _pageNr + 1)
          ),
        ]
      );

    }


    return Ink(
      padding: EdgeInsets.all(mainBoxPadding),
      color: mainContainerBackgroundColor,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (position) {

              int sensitivity = 0;
              if (position.delta.dx < sensitivity) {
                if (_pageNr < maxPages){
                  setState(() {
                    _pageNr = _pageNr + 1;
                  });
                }
              } else if(position.delta.dx > -sensitivity){
                if (_pageNr > 0){
                  setState(() {
                    _pageNr = _pageNr - 1;
                  });
                }
              }
            },
            child: Column(children:[
               Container(
                height: screenHeight,
                child: createPageBlocks()[_pageNr]
            ),
        pageControlBar(),
      ])
    ));
  }
}
