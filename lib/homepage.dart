/*
 * あつもり
 * カブ価メモ君
 *
 * ホームページモジュール
 *
 * 2020/02/51
 * jskny
 */


import 'package:flutter/material.dart';

// ポップ通知
// https://qiita.com/umechanhika/items/734a716dd592e758ba45
// https://buildbox.net/flutter-toast/
import 'package:fluttertoast/fluttertoast.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import "historypage.dart";


// 文字列が数値か判定する
// https://ja.coder.work/so/string/228144
bool isNumeric(String s) {
	if(s == null) {
		return (false);
	}

	return (int.tryParse(s) != null);
}


// 直近の日曜日の日付を算出し、その日付を返す
DateTime getLastSundayDataTime() {
	initializeDateFormatting('ja');
	DateTime dResult = DateTime.now();

	// 当日が日曜日ではないならば、
	// 直前の日曜日まで日付を戻していく
	if (dResult.weekday != DateTime.sunday) {
		for (int i = 0; i < 7; ++i) {
			dResult = dResult.subtract(Duration(days : 1));

			if (dResult.weekday == DateTime.sunday) {
				break;
			}
		}
	}

	return (dResult);
}


// 直近の日曜日の日付を算出し、その日付を返す
String getLastSundayString() {
	String ret = "";
	// 計算結果を文字列にする
	ret = (DateFormat('yyyy/MM/dd').format(getLastSundayDataTime())).toString();
	return (ret);
}


class _InheritedWidgetForPageOfHome extends InheritedWidget {
	_InheritedWidgetForPageOfHome({
	Key key,
	@required Widget child,
	@required this.data,
	}) : super(key: key, child: child);

	final PageWidgetOfHome data;

	@override
	bool updateShouldNotify(_InheritedWidgetForPageOfHome oldWidget) {
		return true;
	}
}


class PageWidgetOfHome extends StatefulWidget {
	PageWidgetOfHome({
		Key key,
		this.child,
	}) : super(key: key);

	final Widget child;

	@override
	PageWidgetOfHomeState createState() => PageWidgetOfHomeState();

	static PageWidgetOfHome of(BuildContext context, {bool rebuild = true}) {
		if (rebuild) {
			return (context.dependOnInheritedWidgetOfExactType<_InheritedWidgetForPageOfHome>().data);
		}

		return (context.findAncestorWidgetOfExactType<_InheritedWidgetForPageOfHome>().data);
	}
}


class PageWidgetOfHomeState extends State<PageWidgetOfHome> {
	// 処理日
	String _systemTimeString = "now loading...";
	// 計算期間
	String _processingTerm = "now loading...";

	// 現在株価入力用
	static int nowPrice = 0;
	static String _inputNowPrice = "";

	// 記帳時
	static String _inputBuyNumber = "";
	static String _inputSellNumber = "";


	@override
	void initState() {
		super.initState();

		// 処理日反映
		initializeDateFormatting('ja');
		_systemTimeString = (DateFormat('yyyy/MM/dd').format(DateTime.now())).toString();

		// 計算期間
		_processingTerm = getLastSundayString() + "-" + _systemTimeString;

		// 各種画面入力ボックスのテキスト処理用変数を初期化
		_inputNowPrice = "";
		_inputBuyNumber = "";
		_inputSellNumber = "";
	}


	@override
	Widget build(BuildContext context) {
		return (_createHomePage(context));
	}


	// ホーム画面
	ListView _createHomePage(BuildContext context) {
		return (
			ListView(
				children: <Widget>[
					Container(
						padding: const EdgeInsets.all(2),
					),

					Column(
						// ボタンを横幅最大まで伸ばすため
						crossAxisAlignment: CrossAxisAlignment.stretch,

						children: <Widget>[
							_createHomePageButtonNowPrice(context),
							_createHomePageButtonBuy(context),
							_createHomePageButtonSell(context)
						]
					),

					_createHomePageCardNowPriceInfo(context),
					_createHomePageCardStocksInfo(context)
				]
			)
		);
	}


	RaisedButton _createHomePageButtonNowPrice(BuildContext context) {
		return (
			RaisedButton(
				padding: const EdgeInsets.all(8.0),
				child: const Text('現在カブ値記帳'),
				onPressed: (){
					showDialog(
						context: context,
						builder: (BuildContext context) {
							return SimpleDialog(
								children: <Widget>[
									Center(
										child: Text("現在カブ価記帳",
										style: TextStyle(
											fontSize: 16.0
										),),
									),

									TextField(
										decoration: new InputDecoration(
											border: OutlineInputBorder(),
											labelText: "カブ価"
										),
										keyboardType: TextInputType.number,

										maxLength: 3,
										onChanged: (text) {
											if (text.length > 0) {
												_inputNowPrice = text;
											}
										}
									),

									Container(
										padding: const EdgeInsets.all(4.0),
										child: Icon(
											Icons.show_chart,
											color: Colors.red,
											size: 18.0
										)
									),

									Center(
										child: RaisedButton(
											onPressed: () {
												if (_inputNowPrice.length <= 0) {
													Fluttertoast.showToast(msg: "カブ価を入力してください。");
													return;
												}

												if (isNumeric(_inputNowPrice) == false) {
													Fluttertoast.showToast(msg: "カブ価に数値を入力してください");
													return;
												}

												int tmp = int.parse(_inputNowPrice);
												if (tmp <= 0) {
													Fluttertoast.showToast(msg: "カブ価には0よりも大きい値を入力してください。");
													return;
												}
												else {
													// 現在株価を更新
													setState(() {
														nowPrice = tmp;
														Navigator.pop(context, 1);
														Fluttertoast.showToast(msg: "現在カブ価を更新しました。");
													});
												}
print(nowPrice);
											},
											child: const Text('記帳')
										)
									)
								],
							);
						}
					);
				}
			)
		);
	}


	// 購入ボタンおよび押下後のダイアログ
	RaisedButton _createHomePageButtonBuy(BuildContext context) {
		return (
			RaisedButton(
				padding: const EdgeInsets.all(8.0),
				child: const Text('購入記帳'),
				onPressed: (){
					showDialog(
						context: context,
						builder: (BuildContext context) {
							return SimpleDialog(
								children: <Widget>[
									Center(
										child: Text("購入記帳",
											style: TextStyle(
												fontSize: 16.0
											)
										)
									),

									TextField(
										decoration: new InputDecoration(
											border: OutlineInputBorder(),
											labelText: "購入数"
										),
										keyboardType: TextInputType.number,

										maxLength: 7,
										onChanged: (text) {
											if (text.length > 0) {
												_inputBuyNumber = text;
											}
										}
									),

									Container(
										padding: const EdgeInsets.all(4.0),
										child: Icon(
											Icons.show_chart,
											color: Colors.green,
											size: 18.0
										)
									),

									Center(
										child: RaisedButton(
											onPressed: (){
												if (nowPrice == 0) {
													Fluttertoast.showToast(msg: "まず、現在カブ価を入力してください。");
													return;
												}
												else if (_inputBuyNumber.length == 0) {
													Fluttertoast.showToast(msg: "購入数を入力してください。");
													return;
												}

												if (isNumeric(_inputBuyNumber) == false) {
													Fluttertoast.showToast(msg: "購入数に数値を入力してください");
													return;
												}

												if (int.parse(_inputBuyNumber) <= 0) {
													Fluttertoast.showToast(msg: "購入数は0よりも大きいな値を入力してください");
													return;
												}

												// 取引記録に追加
												setState(() {
													tradeInfo.add(new TradeInfo.fill(1, nowPrice, int.parse(_inputBuyNumber)));
												});

												Navigator.pop(context, 1);
												Fluttertoast.showToast(msg: "記帳しました。");
print("${nowPrice}:" + _inputBuyNumber);
											},
											child: const Text('記帳')
										)
									)
								]
							);
						}
					);
				}
			)
		);
	}

	// 売却ボタンおよび押下後のダイアログ
	RaisedButton _createHomePageButtonSell(BuildContext context) {
		return (
			RaisedButton(
				padding: const EdgeInsets.all(8.0),
				child: const Text('売却記帳'),
				onPressed: (){
					showDialog(
						context: context,
						builder: (BuildContext context) {
							return SimpleDialog(
								children: <Widget>[
									Center(
										child: Text("売却記帳",
											style: TextStyle(
												fontSize: 16.0
											)
										)
									),

									TextField(
										decoration: new InputDecoration(
											border: OutlineInputBorder(),
											labelText: "売却数"
										),
										keyboardType: TextInputType.number,

										maxLength: 7,
										onChanged: (text) {
											if (text.length > 0) {
												_inputSellNumber = text;
											}
										}
									),

									Container(
										padding: const EdgeInsets.all(4.0),
										child: Icon(
											Icons.show_chart,
											color: Colors.yellow,
											size: 18.0
										)
									),

									Center(
										child: RaisedButton(
											onPressed: (){
												if (nowPrice == 0) {
													Fluttertoast.showToast(msg: "まず、現在カブ価を入力してください。");
													return;
												}
												else if (_inputSellNumber.length == 0) {
													Fluttertoast.showToast(msg: "売却数を入力してください。");
													return;
												}

												if (isNumeric(_inputSellNumber) == false) {
													Fluttertoast.showToast(msg: "購入数に数値を入力してください");
													return;
												}

												if (int.parse(_inputSellNumber) <= 0) {
													Fluttertoast.showToast(msg: "購入数は0よりも大きいな値を入力してください");
													return;
												}

												// 取引記録に追加
												setState(() {
													tradeInfo.add(new TradeInfo.fill(2, nowPrice, int.parse(_inputSellNumber)));
												});

												Navigator.pop(context, 1);
												Fluttertoast.showToast(msg: "記帳しました。");
print("{$nowPrice}:" + _inputSellNumber);
											},
											child: const Text('記帳')
										)
									)
								]
							);
						}
					);
				}
			)
		);
	}


	// 現在株価などの表示カード
	Column _createHomePageCardNowPriceInfo(BuildContext context) {
		return (
			Column(children: [
				Builder(builder: (context) {
					return (
						Card(child: Column(
							children: <Widget>[
								ListTile(
									title:    Text("現在カブ価：${(nowPrice == 0 ? "【現在カブ価未記帳】" : "${nowPrice} ベル")}"),
									subtitle: Text("現在日付　：" + _systemTimeString)
								)
							])
						)
					);
				}),

				Card(child: Column(
					children: <Widget>[
						ListTile(
							title:    Text("計算範囲"),
							subtitle: Text(_processingTerm),
						)
					])
				)
			])
		);
	}


	// 保有株式数などの情報表示カード
	Card _createHomePageCardStocksInfo(BuildContext context) {
		return (
			Card(
				child: Column(children: [
					ListTile(
						title: Text("保有カブ数：${possessionStockNum} カブ")
					),
					ListTile(
						title: Text("平均取得額：${possessionStockAvePrice}　ベル")
					),
					ListTile(
						title: Text("評価損益額：" + (
							((possessionStockNum == 0) ? "【カブ未保有】" :
								(nowPrice == 0) ?
								"【現在カブ価未記帳】" : 
								((nowPrice < possessionStockAvePrice) ?
										"【損失発生】" + ((possessionStockAvePrice - nowPrice) * possessionStockNum).toString() :
										"【利益発生】" + ((nowPrice - possessionStockAvePrice) * possessionStockNum).toString()
									) + "ベル"
								)
							)
						)
					),
					ListTile(
						title: Text("利益率　　：")
					)
				])
			)
		);
	}
}
