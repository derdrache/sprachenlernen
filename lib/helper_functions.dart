import 'package:flutter/material.dart';

void openNewPageWindow(context, page){
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return page;
        }
      )
  );
}