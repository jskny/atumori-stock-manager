import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 【参考文献】
// 認証関連
// https://qiita.com/unsoluble_sugar/items/95b16c01b456be19f9ac
// タブバー関連
// https://flutter.ctrnost.com/basic/navigation/bottomnavigationbar/
// https://github.com/fablue/building-a-social-network-with-flutter
// 取引履歴のListView関連
// https://flutter.ctrnost.com/basic/layout/listview/

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'あつもり トレードロガー',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'あつもり トレードロガー'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // タブ関連
  PageController _pageController;
  int _currentIndex = 0;
  List<Widget> _pageWidgets = new List(2);


  @override
  void initState() {
    super.initState();
    _pageController = new PageController();

    _pageWidgets[0] = new Container(color: Colors.white);
    _pageWidgets[1] = new ListView(
        children: [
          _historyItemBought(10, 100),
          _historyItemBought(15, 50)
        ],
      );

  }

  @override
  void dispose(){
    super.dispose();
    _pageController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.title)
            )
          ]
        )
      ),

      body: new PageView(
        children : _pageWidgets,

        // ページ遷移
        controller: _pageController,
        onPageChanged: onPageChanged
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.history), title: Text('History')),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blueAccent,
        onTap: onNavigationTapped,
        type: BottomNavigationBarType.fixed,
      )
    );
  }


  // 下部のナビゲーションバーがタップされたときの挙動
  void onNavigationTapped(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease
    );
  }

  // ページ切り替え時
  void onPageChanged(int index) {
    setState((){
      this._currentIndex = index;
    });
  }


  // 取引記録（購入）のオブジェクト
  Widget _historyItemBought(int price, int count) {
    return GestureDetector(
      child:Container(
        padding: EdgeInsets.all(8.0),
        decoration: new BoxDecoration(
         border: new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
        ),
 
      child: Row(
          children: <Widget>[
          Container(
            margin: EdgeInsets.all(10.0),
            child:Icon(Icons.check_circle_outline),
          ),
          Text(
            "【購入】\n取得単価：${price} ベル\n約定数：${count} カブ\n約定金額：${price * count}ベル\n購入日：2020/05/17",
            style: TextStyle(
              color:Colors.white,
              fontSize: 18.0
            ),
          ),
          ],
        )
      ),

      onTap: () {
       print("onTap called.");
      },
    );
  }


}
