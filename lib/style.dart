import 'package:flutter/material.dart';

var theme = ThemeData( // style 태그와 비슷 materialApp
    iconTheme: IconThemeData(color: Colors.black, size: 30),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        // side: BorderSide(color: Colors.black, width: 1.0)
      )
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      actionsIconTheme: IconThemeData(color: Colors.black),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.black45,
      unselectedItemColor: Colors.black45
)
);