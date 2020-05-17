import 'dart:html';

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

		// ホーム画面
		_pageWidgets[0] = _createHomePage();
		// 取引履歴画面
		_pageWidgets[1] = new ListView(
			children: [
				_historyItemBought(10, 100),
				_historyItemBought(15, 50),
				_historyItemSell(100, 50, 80),
				_historyItemSell(120, 240, 180)
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


			// 左側メニュー
			drawer: Drawer(
					child: _createLeftMenu()
			),

			body: new PageView(
				children : _pageWidgets,

				// ページ遷移
				controller: _pageController,
				onPageChanged: onPageChanged
			),

			// 下メニューバー
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
					border: new Border(bottom: BorderSide(width: 1.0, color: Colors.grey)
				)
			),

			child: Row(
					children: <Widget>[
						Container(
							margin: EdgeInsets.all(10.0),
							child:Icon(Icons.check_circle_outline),
						),
						Text(
							"【購入】\n取得単価：${price} ベル\n約定数　：${count} カブ\n約定金額：${price * count}ベル\n購入日　：2020/05/17",
							style: TextStyle(
								color:Colors.white,
								fontSize: 14.0
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


	// 取引記録（売却）のオブジェクト
	Widget _historyItemSell(int sellPrice, int sellCount, int boughtPrice) {
		return GestureDetector(
			child:Container(
					padding: EdgeInsets.all(8.0),
					decoration: new BoxDecoration(
					border: new Border(
						bottom: BorderSide(width: 1.0, color: Colors.grey)
					)
				),

				child: Row(
						children: <Widget>[
							Container(
								margin: EdgeInsets.all(10.0),
								child:Icon(Icons.check_circle_outline),
							),
							Text(
								"【売却】${(sellPrice - boughtPrice < 0) ? "＜損失発生＞" : "＜利益発生＞"}\n売却単価：${boughtPrice} ベル\n約定数　：${sellCount} カブ\n約定金額：${sellPrice * sellCount}ベル\n損益計算：${(sellPrice - boughtPrice) > 0 ? "+" : "-"} ${((sellPrice - boughtPrice) * sellCount).abs()}\n売却日　：2020/05/17",
								style: TextStyle(
									color: (sellPrice - boughtPrice < 0) ? Colors.lightBlue : Colors.red,
									fontSize: 14.0
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

	// 【左メニュー】
	ListView _createLeftMenu() {
		return (new ListView(
				padding: EdgeInsets.zero,

				children: <Widget>[
					ListTile(
						title: Text(
							"あつもり トレードロガー",
							style: new TextStyle(
								color: Colors.white,
								fontSize: 16.0
								)
						)
					),
					ListTile(
						title: Text("Settings"),
						onTap: () {
							print("setting.");
						},
					),
					ListTile(
						title: Text("(c) jskny")
					)
				]
			)
		);
	}


	// ホーム画面
	Container _createHomePage() {
		return (new Container(
			child: ListView(
				children: [
					Column(
						children: <Widget>[
							Column(
								// ボタンを横幅最大まで伸ばすため
								crossAxisAlignment: CrossAxisAlignment.stretch,

								children: <Widget>[
									RaisedButton(
										padding: const EdgeInsets.all(8.0),
										child: const Text('現在カブ値記帳'),
										onPressed: (){}
									),

									RaisedButton(
										padding: const EdgeInsets.all(8.0),
										child: const Text('購入記帳'),
										onPressed: (){}
									),

									RaisedButton(
										padding: const EdgeInsets.all(8.0),
										child: const Text('売却記帳'),
										onPressed: (){}
									)

								]
							),

							Card(child: Column(
								children: <Widget>[
									const ListTile(
										title: Text("現在カブ価：")
									)
								])
							),

							Card(
								child: Column(children: [
									ListTile(
										title: Text("保有株数　：")
									),
									ListTile(
										title: Text("平均取得額：")
									),
									ListTile(
										title: Text("評価損益額：")
									),
									ListTile(
										title: Text("利益率　　：")
									)
								])
							)
						]
					),
				]
			)
		));
	}


}
