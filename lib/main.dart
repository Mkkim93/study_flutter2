import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './style.dart' as style; // 가져온 변수 작명 가능 (as)

void main() {
  runApp(MaterialApp(theme: style.theme, home: MyApp()));
}

// 스타일 지정해서 마이앱에서 a 변수 바인딩
// var a = TextStyle();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int tab = 0;
  List<dynamic> instarList = [];
  final PageController _pageController = PageController();

  getData() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    return jsonDecode(result.body);
  }

  // 위젯이 처음 load 될때 실행
  @override
  void initState() {
    super.initState();
    getData().then((data) {
      instarList = data;// 실제 json 데이터 출력
      print(instarList);
    });
  }

  void _onTabChange(int index) {
    setState(() => tab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: const CustomAppBar()),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            tab = index;
          });
        },
        children: [
          CustomBody(
              instarList: instarList,
          ),
          CustomShopBody(),
        ],
      ),
      bottomNavigationBar: CustomBottonNavBar(
        tab: tab,
        onTabChange: _onTabChange,
      ),
    );
  }
}

var customAppBarStyle = GoogleFonts.lobster(fontSize: 22, color: Colors.white);
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(context) {
    return Row(
      children: [
        Text('Instargram', style: customAppBarStyle),
        Padding(padding: const EdgeInsets.all(100.0)),
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


class CustomBody extends StatefulWidget {
  CustomBody({super.key, required this.instarList});
  final List<dynamic> instarList;

  @override
  State<CustomBody> createState() => _CustomBodyState();
}

class _CustomBodyState extends State<CustomBody> {
  @override
  Widget build(context) {
    return ListView.builder(itemCount: widget.instarList.length, itemBuilder: (c, i){
      final item = widget.instarList[i];
      final likes = int.parse(item['likes'].toString());
      return Column(
        children: [
          Image.network(item['image']),
          Container(

            constraints: BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('좋아요 ${item['likes']}'),
                Text(item['user']),
                Text(item['content']),
                Text(item['date'])
              ],
            ),
          )
        ],
      );
    });
  }
}

class CustomBottonNavBar extends StatelessWidget {
  CustomBottonNavBar({super.key, this.tab, this.onTabChange});
  var tab;
  var onTabChange;
  @override
  build(context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: tab, // ❗️현재 탭 반영 반드시 적용 (없어도 되지만 현재 pageView 와의 일관성을 위해 명시적으로 추가해주는게 좋음)
      onTap: (i){
        if (onTabChange != null) onTabChange!(i);
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: '샵',
        ),
      ],
    );
  }
}

class CustomShopBody extends StatelessWidget {
  const CustomShopBody({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.asset(
                    'assets/gene.png', // 샘플 이미지 경로
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('상품명', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('₩29,900', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('장바구니'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
