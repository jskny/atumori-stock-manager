import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';

import 'homepage.dart';
import "historypage.dart";
import 'settings.dart';

import 'common.dart';

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
			title: 'カブ価メモ君',
			theme: ThemeData.dark(),
			home: MyHomePage(title: 'カブ価メモ君'),
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
	// 表示しているページ番号
	int _currentIndex = 0;

	// タブ関連
	PageController _pageController;
	List<Widget> _pageWidgets = new List(3);

	@override
	void initState() {
		super.initState();
		loadDatabase();

		_pageController = new PageController();

		// ホーム画面
		_pageWidgets[0] = new PageWidgetOfHome();
		// 取引履歴画面
		_pageWidgets[1] = new PageWidgetOfHistory();
		// セッティング画面
		_pageWidgets[2] = new PageWidgetOfSettings();
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
							child: Icon(
								Icons.show_chart,
								color: Colors.red,
								size: 36.0
							)
						)
					]
				)
			),

			body: StreamBuilder(
				stream: controllerStream.stream,
				builder: (context, snapshot) {
					return (new PageView(
						children : _pageWidgets,

						// ページ遷移
						controller: _pageController,
						onPageChanged: onPageChanged
					));
				}
			),

			// 下メニューバー
			bottomNavigationBar: BottomNavigationBar(
				items: <BottomNavigationBarItem>[
					BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
					BottomNavigationBarItem(icon: Icon(Icons.history), title: Text('History')),
					BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text('Settings'))
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
}

