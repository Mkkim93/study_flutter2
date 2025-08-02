import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData( // style 태그와 비슷 materialApp
        iconTheme: IconThemeData(color: Colors.black, size: 30),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          actionsIconTheme: IconThemeData(color: Colors.black),
        ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.white,
          ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        )
      ),
      home: MyApp()
    )
  );
}

// 스타일 지정해서 마이앱에서 a 변수 바인딩
// var a = TextStyle();

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: CustomAppBar()),
      body: CustomBody(),
      bottomNavigationBar: CustomBottonNavBar(),
    );
  }
}

var customAppBarStyle = GoogleFonts.lobster(
  fontSize: 22,
  color: Colors.white,
);

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(context) {
    return Row(
      children: [
        Text('Instargram', style: customAppBarStyle,),
        Padding(padding: const EdgeInsets.all(100.0),),
        IconButton(
          onPressed: () {
            print('추가');
          },
          icon: Icon(Icons.add_box_outlined),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.white), // 아이콘 색상
          ),
        ),
      ],
    );
  }
}

Map<String, List<Object>> carMap = {};

class MyStateApp extends StatefulWidget {
  const MyStateApp({super.key});

  @override
  State<MyStateApp> createState() => _MyStateAppState();
}

class _MyStateAppState extends State<MyStateApp> {
  @override
  Widget build(context) {
    return

  }
}


class CustomBody extends StatelessWidget {
  CustomBody({super.key});

  @override
  Widget build(context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/kona.png',
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('좋아요', style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('johnKim'),
                    Text('8월 7일'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomBottonNavBar extends StatelessWidget {
  CustomBottonNavBar({super.key});

  @override
  build(context) {
    return BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.home),
            SizedBox(width: 150), // 두 번째 간격
            Icon(Icons.shopping_cart_outlined)
          ],
        )
    );
  }
}



