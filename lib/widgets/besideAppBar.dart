import 'package:flutter/material.dart';

class BesideAppBar extends StatelessWidget implements PreferredSizeWidget {
  Size get preferredSize => Size.fromHeight(50);
  String title;


  BesideAppBar({required this.title});


  Widget build(BuildContext context) {

    return Container(
          color: Theme.of(context).primaryColor,
          child: Row(
            children:[
              FloatingActionButton(
                heroTag: null,
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(),
                child: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white
                  ),
                )
              ),
            ],
          )

    );
  }
}

