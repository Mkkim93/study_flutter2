
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';
import 'dart:convert';
import './style.dart' as style; // 가져온 변수 작명 가능 (as)
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photofilters/photofilters.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
      theme: style.theme,
      // initialRoute: '/',
      // routes: {
      //   '/' : (c) => Text('첫페이지'),
      //   '/detail' : (c) => Text('둘째페이지')
      // },
      home: MyApp()
  ));
}

// 스타일 지정해서 마이앱에서 a 변수 바인딩
// var a = TextStyle();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  List<dynamic> instarList = [];
  final PageController _pageController = PageController();
  var userImage;

  void addData(List<dynamic> newData) {
    setState(() {
      instarList.addAll(newData);
    });
  }

  getData() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    if (result.statusCode == 200) {
      return jsonDecode(result.body);
    } else {
      print('실패');
    }
  }

  // 위젯이 처음 load 될때 실행
  @override
  void initState() {
    super.initState();
    getData().then((data) {
      setState(() {
        instarList = data as List<dynamic>;
      });
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
      appBar: AppBar(title: CustomAppBar(
          userImage: userImage,
          instarList: instarList,
          onAddData: addData,
        onChangeTab: _onTabChange, // 👈 추가
      )),
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
            onAddData: addData, // 👈 콜백 함수 넘기기
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

class CustomAppBar extends StatefulWidget {
  CustomAppBar({super.key,
    this.userImage,
    required this.instarList,
    required this.onAddData,
    this.onChangeTab});

  var userImage;
  List<dynamic> instarList;
  final void Function(List<dynamic>)? onAddData; // ✅
  final void Function(int)? onChangeTab;
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(context) {
    return Row(
      children: [
        Text('Instargram', style: GoogleFonts.lobster(fontSize: 22, color: Colors.white)),
        const Spacer(),
        IconButton(
          onPressed: () async {
            // ✅ 권한 한 번에 요청 (Android 13+ photos / 카메라)
            final statuses = await [Permission.photos, Permission.camera].request();
            if (!(statuses[Permission.photos]?.isGranted ?? false) ||
                !(statuses[Permission.camera]?.isGranted ?? false)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('카메라/사진 접근 권한이 필요합니다.')),
              );
              return;
            }

            var picker = ImagePicker();
            var image = await picker.pickImage(source: ImageSource.gallery);

            if (image == null) return;
            if (image != null) {
              setState(() {
                widget.userImage = File(image.path);
              });
            }
            if (!mounted) return;

            final newPost = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Upload(
                  imageFile: widget.userImage,
                ),
              ),
            );


            if (newPost != null) {
              widget.onAddData?.call([newPost]);
              widget.onChangeTab?.call(0);

              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('업로드 완료!')
                  )
              );
            }

            // Navigator.push(context,
            //   MaterialPageRoute(builder: (context) => Upload(
            //     imageFile: widget.userImage,
            //   ) )
            // );
          },
          icon: const Icon(Icons.add_box_outlined, color: Colors.white),
        ),
      ],
    );
  }
}

class CustomBody extends StatefulWidget {
  const CustomBody({
    super.key,
    required this.instarList,
    this.onAddData,
  });

  final List<dynamic> instarList;
  final void Function(List<dynamic>)? onAddData; // ✅ 타입 명시
  @override
  State<CustomBody> createState() => _CustomBodyState();
}

class _CustomBodyState extends State<CustomBody> {
  bool isLoading = false;
  final scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (!isLoading &&
          scroll.position.pixels >= scroll.position.maxScrollExtent - 100) {
          getMore();
      }
    });
  }

  Future<void> getMore() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final result = await http.get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    if (result.statusCode == 200) {
      final json = jsonDecode(result.body);
      // more1.json은 단일 객체(Map) -> 리스트로 감싸서 추가
      widget.onAddData?.call(json is List ? json : [json]);
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    scroll.dispose(); // ✅ 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(context) {
    return ListView.builder(
      controller: scroll,
      itemCount: widget.instarList.length,
      itemBuilder: (c, i) {
        final item = widget.instarList[i];
        final imagePath = item['image'];

        // 네트워크/로컬 파일 구분
        final imageWidget = imagePath.toString().startsWith('http')
            ? Image.network(imagePath)
            : Image.file(File(imagePath));

        return Column(
          children: [
            imageWidget,
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('좋아요 ${item['likes']}'),
                  Text('글쓴이 ${item['user']}'),
                  Text('내용 ${item['content']}'),
                  Text(item['date']),
                ],
              ),
            ),
          ],
        );
      },
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

class CustomBottonNavBar extends StatelessWidget {
  CustomBottonNavBar({super.key, this.tab, this.onTabChange});
  final tab;
  final onTabChange;
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

class Upload extends StatefulWidget {
  const Upload({super.key, required this.imageFile});
  final File imageFile;

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final formattedDate = DateFormat('MMM d').format(DateTime.now());

  @override
  void dispose() {
    _contentController.dispose();
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이미지 업로드')),
      body: Column(
        children: [
          Image.file(widget.imageFile),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: '내용을 입력해주세요',
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _userController,
            decoration: const InputDecoration(
              labelText: '이름을 입력해주세요',
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newPost = {
                "id": DateTime.now().millisecondsSinceEpoch,
                "image": widget.imageFile.path,
                "likes": 0,
                "date": formattedDate,
                "content": _contentController.text,
                "liked": false,
                "user": _userController.text
              };
              Navigator.pop(context, newPost); // ✅ 새 글 반환
            },
            child: const Text("저장"),
          ),
        ],
      ),
    );
  }
}
