/*
 * あつもり
 * カブ価メモ君
 *
 * 設定等画面
 *
 * 2020/07/23
 * jskny
 */

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import "common.dart";


class _InheritedWidgetForPageOfSettings extends InheritedWidget {
	_InheritedWidgetForPageOfSettings({
	Key key,
	@required Widget child,
	@required this.data,
	}) : super(key: key, child: child);

	final PageWidgetOfSettings data;

	@override
	bool updateShouldNotify(_InheritedWidgetForPageOfSettings oldWidget) {
		return true;
	}
}


class PageWidgetOfSettings extends StatefulWidget {
	PageWidgetOfSettings({
		Key key,
		this.child,
	}) : super(key: key);

	final Widget child;

	@override
	PageWidgetOfSettingsState createState() => PageWidgetOfSettingsState();

	static PageWidgetOfSettings of(BuildContext context, {bool rebuild = true}) {
		if (rebuild) {
			return (context.dependOnInheritedWidgetOfExactType<_InheritedWidgetForPageOfSettings>().data);
		}

		return (context.findAncestorWidgetOfExactType<_InheritedWidgetForPageOfSettings>().data);
	}
}


class PageWidgetOfSettingsState extends State<PageWidgetOfSettings> {
	@override
	void initState() {
		super.initState();

		calcStockValues();
	}

	@override
	Widget build(BuildContext context) {
		return (_createSettingsPage(context));
	}


	// 設定ページ
	Container _createSettingsPage(BuildContext context) {
		return (new Container(
			child: ListView(
				children: <Widget>[
					Column(
						children: <Widget>[
							Card(
								child: Column(
									children: [
										ListTile(
											title: Text(
												"カブ価メモ君",
												style: new TextStyle(
													color: Colors.white,
													fontSize: 16.0
												)
											)
										),
										ListTile(
											title: Text(
												"【使い方】\n"
												"(1) 【日曜日】\n"
												"  (i)  「現在カブ価記帳」\n"
												"  (ii) 「購入記帳」\n"
												"(2) 【月曜日から土曜日】\n"
												"  (i) 日々カブ価をチェック\n"
												"    (a)  「現在カブ価記帳」\n"
												"    (b) 「売却記帳」\n",
												style: new TextStyle(
													color: Colors.lightGreen,
													fontSize: 14.0
												)
											)
										),
									]
								)
							),

							Card(
								child: ListTile(
									title: Text(
										"【よくあるご質問】\n"
										"Q1、購入記帳をしたところ、日曜日の日付で取引履歴が作成されていました。\n"
										"A、あつもりでは日曜日の午前中のみカブを購入できるため、"
										"購入日付については日曜日の日付をセットするようにしています（日曜日以外の曜日でカブを買えないため）。",
										style: new TextStyle(
											color: Colors.lightGreen,
											fontSize: 14.0
										)
									),
								)
							),

							Card(
								child: ListTile(
									title: Text("(c) jskny")
								)
							),

							Center(
								child: RaisedButton(
									onPressed: (){
										showDialog(
											context: context,
											builder: (BuildContext context) {
												return SimpleDialog(
													children: <Widget>[
														Center(
															child: Text("本当に初期化しますか？",
																style: TextStyle(
																	fontSize: 16.0
																),
															),
														),

														Center(
															child: RaisedButton(
																onPressed: (){
																	setState(() {
																		tradeInfo.clear();
																		delAllDatabase();

																		Navigator.pop(context, 1);
																		Fluttertoast.showToast(msg: "初期化しました");
																	});
																},

																child: const Text('取引履歴クリア')
															)
														),
													]
												);
											}
										);
									},

									child: const Text('取引履歴クリア')
								),
							)
						]
					),
				]
			)
		));
	}
}

