import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:manlivetoung/provider/myProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key, required this.title});

  final String title;

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  var _cosmeticDataTest = {};

  var _cosmeticData = {};
  var _setLoading = true;
  final category = [
    'skin',
    'lotion',
    'essense',
    'waterCream',
    'mask',
    'shaving'
  ];
  final engcategory = [
    'skin',
    'lotion',
    'essense',
    'waterCream',
    'mask',
    'shaving'
  ];
  final tabBarcategory = ['스킨', '로션', '에센스', '수분크림', '마스크팩', '쉐이빙크림'];
  final skinTypeDescription = {
    '건성':
        '건성 피부\n메마른 피부에 수분을 충전하고 건조함을 악화시키지 않도록 스킨케어 각 단계마다 수분을 유지하거나 공급하는 제품을 사용해야 합니다!',
    "지성":
        "지성 피부\n번들거리는 피부로 인해 종종 트러블이 발생할 수 있어요. 항상 수분크림과 진정 성분이 있는 보습제를 사용해야합니다!",
    "복합성": "복합성 피부\n특히 T존이라고 불리는 이마,코,턱에 유분이 생기지 않도록 해야하고 뺨에는 보습을 충전해야 됩니다!"
  };
  dynamic datas;
  dynamic type;
  List<Map<String, String>> user = [];
  late int _currentPageIndex;

  // get http => null;
  var serverResponse;

  setData() async {
    datas.forEach((k, v) => {
          for (var i = 0; i < v.length; i++)
            {db.collection('건성cosmetics').doc(v[i]['name']).set(v[i])}
        });
  }

  getData(type) async {
    _cosmeticData = {};

    var url = Uri.parse('http://10.0.2.2:8080/cosmeticapi/cosmetic');
    var response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"type": type}));

    var abc = jsonDecode(response.body);

    setState(() {
      _cosmeticData = abc as dynamic;
    });

    setState(() {
      _setLoading = true;
    });

    setState(() {
      _setLoading = false;
    });

    final cosmetics = db.collection("cosmetics");
    cosmetics.orderBy("type").orderBy("star", descending: false);
  }

  setStar(name, star, review) async {
    setState(() {
      _setLoading = true;
    });

    final cosmetics = db.collection("${type}cosmetics");
    // cosmetics.where("type", isEqualTo: 'skin').set({"star": '1'});

    await cosmetics
        .doc(name)
        .update({"star": (double.parse(star) + 0.01).toStringAsFixed(2)}).then(
            (value) => print("DocumentSnapshot successfully updated!"),
            onError: (e) => print("Error updating document $e"));

    await cosmetics.doc(name).update({"review": (int.parse(review) + 1)}).then(
        (value) => print("DocumentSnapshot successfully updated!"),
        onError: (e) => print("Error updating document $e"));

    getData(type);
  }

  void sendDataToServer(String text) async {
    var url = Uri.parse('http://127.0.0.1:8000/upload/');
    var response = await http.post(url, body: {'text': text});
    setState(() {
      serverResponse = response.body;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    type = context.watch<UserInfos>().type.toString();

    getData(type);
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPageIndex) {
      case 0:
        return DefaultTabController(
            length: category.length,
            child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text(
                    "MAN LIVE YOUNG",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  backgroundColor: Colors.white,
                  actions: [],
                  bottom: TabBar(
                    tabs: tabBarcategory.map((String choice) {
                      return Tab(text: choice);
                    }).toList(),
                    isScrollable: true,
                    indicatorColor: Colors.transparent, // indicator 없애기
                    unselectedLabelColor: Colors.black, // 선택되지 않은 tab 색
                    labelColor: Colors.green,
                  ),
                ),
                body: _setLoading
                    ? Center(
                        // children: [],
                        child: Text('별점을 분석하는 중입니다...'))
                    : TabBarView(
                        children: category.map((String choice) {
                          return Center(
                              // children: [],
                              child: Column(children: <Widget>[
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  "${context.watch<UserInfos>().nickname.toString()}님의 \'${context.watch<UserInfos>().type.toString()}\'피부 타입에 알맞는 추천 결과입니다.",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )),
                            Expanded(
                                child: ListView.builder(
                                    key: const PageStorageKey("LIST_VIEW"),
                                    itemCount: _cosmeticData[choice].length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                              title: const Text('리뷰를 남겨주세요'),
                                              content: const TextField(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText:
                                                      '긍정/부정을 판단합니다.', // 힌트
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () => {
                                                    Navigator.pop(
                                                        context, 'Cancel')
                                                  },
                                                  child: const Text('나중에'),
                                                ),
                                                TextButton(
                                                  onPressed: () => {
                                                    Navigator.pop(
                                                        context, 'OK'),
                                                    setStar(
                                                        _cosmeticData[choice]
                                                            [index]["name"],
                                                        _cosmeticData[choice]
                                                                [index]["star"]
                                                            .toString(),
                                                        _cosmeticData[choice]
                                                                    [index]
                                                                ["review"]
                                                            .toString())
                                                  },
                                                  child: const Text('제출하기'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Center(
                                              child: Row(
                                            children: [
                                              Container(
                                                child: Text(
                                                    (index + 1).toString(),
                                                    style: const TextStyle(
                                                        fontSize: 40)),
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    top: 20,
                                                    bottom: 20),
                                              ),
                                              ClipRRect(
                                                  child: Image.asset(
                                                _cosmeticData[choice][index]
                                                        ["image"]
                                                    .toString(),
                                                height: 100,
                                                width: 100,
                                              )),
                                              Container(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _cosmeticData[choice][index]
                                                        ["name"],
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                      child: Row(children: [
                                                    Image.asset(
                                                        'assets/images/star.png'),
                                                    Text(
                                                        "${_cosmeticData[choice][index]["star"]}\(${_cosmeticData[choice][index]['review']}\)"),
                                                  ])),
                                                  Text(
                                                      _cosmeticData[choice]
                                                          [index]["comment"],
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ))
                                                ],
                                              ))
                                            ],
                                          )),
                                        ),
                                      );
                                    }))
                          ]));
                        }).toList(),
                      ),
                bottomNavigationBar: BottomNavigationBar(
                    onTap: (int index) {
                      if (index == 1) {
                        Future.delayed(const Duration(milliseconds: 5000), () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('서비스의 전반적인 만족도를 평가해주세요'),
                              content: const TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: '긍정/부정을 판단합니다.', // 힌트
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      {Navigator.pop(context, 'Cancel')},
                                  child: const Text('별로에요'),
                                ),
                                TextButton(
                                  onPressed: () => {
                                    Navigator.pop(context, 'OK'),
                                  },
                                  child: const Text('만족해요'),
                                ),
                              ],
                            ),
                          );
                        });
                      }
                      ;
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    currentIndex: _currentPageIndex,
                    selectedItemColor: Colors.green,
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.storefront),
                        label: '제품추천',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.star),
                        label: '루틴추천',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: '내정보',
                      ),
                    ])));
        break;
      case 1:
        return DefaultTabController(
            length: category.length,
            child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text(
                    "루틴추천",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  backgroundColor: Colors.white,
                  actions: [],
                ),
                body: Column(
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        child: Column(children: [
                          Text(
                            "${skinTypeDescription[context.watch<UserInfos>().type.toString()]}",
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            "\n\"${context.watch<UserInfos>().nickname.toString()}\"님의 피부타입(${context.watch<UserInfos>().type.toString()}) 맞춤 제품들을 추천해드릴게요.",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Georgia'),
                          )
                        ]),
                        decoration: BoxDecoration(
                          color: Colors.green[300],
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        )),
                    Expanded(
                        child: ListView.builder(
                            key: const PageStorageKey("LIST_VIEW"),
                            itemCount: category.length - 1,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemBuilder: (context, index) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                          "${index + 1}단계: ${tabBarcategory[index]}",
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      padding: const EdgeInsets.only(left: 0),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black)),
                                      ),
                                      child: Row(children: [
                                        ClipRRect(
                                            child: Image.asset(
                                          _cosmeticData[category[index]][0]
                                                  ["image"]
                                              .toString(),
                                          height: 100,
                                          width: 100,
                                        )),
                                        Container(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _cosmeticData[category[index]][0]
                                                  ["name"],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                                child: Row(
                                              children: [
                                                Image.asset(
                                                    'assets/images/star.png'),
                                                Text(_cosmeticData[
                                                    category[index]][0]["star"])
                                              ],
                                            )),
                                            Text(
                                              _cosmeticData[category[index]][0]
                                                  ["comment"],
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ))
                                      ]),
                                    )
                                  ],
                                )),
                              );
                            })),
                  ],
                ),
                bottomNavigationBar: BottomNavigationBar(
                    onTap: (int index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    currentIndex: _currentPageIndex,
                    selectedItemColor: Colors.green,
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.storefront),
                        label: '제품추천',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.star),
                        label: '루틴추천',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: '내정보',
                      ),
                    ])));
        break;
      case 2:
        return DefaultTabController(
            length: category.length,
            child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text(
                    "내정보",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  backgroundColor: Colors.white,
                  actions: [],
                ),
                body: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: 350,
                            margin: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Image.asset(
                                          "assets/images/profile.png"),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 10)),
                                  Container(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "    닉네임: ${context.watch<UserInfos>().nickname.toString()}",
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                          Text(
                                            "    아이디: ${context.watch<UserInfos>().id.toString()}",
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                          Text(
                                            "피부타입: ${context.watch<UserInfos>().type.toString()}",
                                            style: const TextStyle(
                                                fontFamily: 'Georgia',
                                                fontSize: 15),
                                          )
                                        ]),
                                  ),
                                ]),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.7),
                                  spreadRadius: 0,
                                  blurRadius: 5.0,
                                  offset: Offset(
                                      0, 10), // changes position of shadow
                                ),
                              ],
                            )),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/skinTest'),
                          child: const Text('피부타입 테스트 다시하기'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/profileEdit'),
                          child: const Text('프로필 수정하기',
                              style: TextStyle(color: Colors.blue)),
                        )
                      ]),
                ),
                bottomNavigationBar: BottomNavigationBar(
                    onTap: (int index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    currentIndex: _currentPageIndex,
                    selectedItemColor: Colors.green,
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.storefront),
                        label: '제품추천',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.star),
                        label: '루틴추천',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: '내정보',
                      ),
                    ])));
        break;
    }
    ;
    return DefaultTabController(length: category.length, child: Scaffold());
  }
}
