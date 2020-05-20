import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// ポップ通知
// https://qiita.com/umechanhika/items/734a716dd592e758ba45
// https://buildbox.net/flutter-toast/
import 'package:fluttertoast/fluttertoast.dart';

// 【参考文献】
// 認証関連
// https://qiita.com/unsoluble_sugar/items/95b16c01b456be19f9ac
// タブバー関連
// https://flutter.ctrnost.com/basic/navigation/bottomnavigationbar/
// https://github.com/fablue/building-a-social-network-with-flutter
// 取引履歴のListView関連
// https://flutter.ctrnost.com/basic/layout/listview/


// 取引ログ格納用構造体
class TradeInfo {
	// 取引区分（０＝未指定、１＝買付、２＝売却）
	int type;

	// 取引単価
	int price;

	// 取引個数
	int number;

	// 処理日付等
	int date;

	// 初期化だけをするコンストラクタ
	TradeInfo() : 
		this.type = 0,
		this.price = 0,
		this.number = 0,
		this.date = 0;


	// 取引区分、単価価格、数量
	TradeInfo.fill(int t, int p, int n) {
		this.type = t;
		this.price = p;
		this.number = n;
	}


	// 表示
	void disp() {
		// 取引区分：単価：個数
		// Buy, Sell, Null
		print("${this.type == 1 ? "B" : (this.type == 2 ? "S" : "N") }, ${this.price}, ${this.number}");
	}
}

void main() {
	runApp(MyApp());
}


// 文字列が数値か判定する
// https://ja.coder.work/so/string/228144
bool isNumeric(String s) {
	if(s == null) {
		return (false);
	}

	return (int.tryParse(s) != null);
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
	// タブ関連
	PageController _pageController;
	// 表示しているページ番号
	int _currentIndex = 0;
	List<Widget> _pageWidgets = new List(3);

 	// 取引履歴
	List<TradeInfo> _tradeInfo = new List<TradeInfo>();

	// 処理日
	String _systemTimeString = "now loading...";

	// 現在株価入力用
	int _nowPrice = 0;
	String _inputNowPrice = "";

	// 記帳時
	String _inputBuyPrice = "", _inputBuyNumber = "";
	String _inputSellPrice = "", _inputSellNumber = "";


	// 保有カブ数
	int _possessionStockNum = 0;
	int _possessionStockAvePrice = 0;

	@override
	void initState() {
		super.initState();
		_pageController = new PageController();


		// 買付ダミー
		this._tradeInfo.add(new TradeInfo.fill(1, 50, 150));
		this._tradeInfo.add(new TradeInfo.fill(1, 15, 50));

		// 売却ダミー
		this._tradeInfo.add(new TradeInfo.fill(2, 35, 200));
		this._tradeInfo.add(new TradeInfo.fill(2, 30, 120));


		// 処理日反映
		initializeDateFormatting('ja');
		_systemTimeString = (DateFormat('yyyy/MM/dd').format(DateTime.now())).toString();

		// 現在株価
		_nowPrice = 0;
		_inputNowPrice = "";

		// 保有株式数等計算
		for (int i = 0; i < this._tradeInfo.length; ++i) {
			// 日付が先週のものは計算除外
			// TODO:

			if (this._tradeInfo[i].type == 1) {
				// 買付
				_possessionStockAvePrice += this._tradeInfo[i].price * this._tradeInfo[i].number;
				_possessionStockNum += this._tradeInfo[i].number;
			}
		}
		if (_possessionStockNum > 0) {
			_possessionStockAvePrice = _possessionStockAvePrice ~/ _possessionStockNum;
		}

		// ホーム画面
		_pageWidgets[0] = _createHomePage();
		// 取引履歴画面
		_pageWidgets[1] = new ListView.builder(
			itemCount: this._tradeInfo.length,
			itemBuilder: (context, int index) {
				// 買付の場合
				if (this._tradeInfo[index].type == 1) {
					return (_historyItemBought(this._tradeInfo[index].price, this._tradeInfo[index].number));
				}
				// 売却の場合
				else if (this._tradeInfo[index].type == 2) {
					// 平均取得残高計算
					int tmpPrice = 0;
					int tmpCnt = 0;

					// ログから平均取得残高を計算
					for (int i = 0; i < this._tradeInfo.length; ++i) {
						// 日付が先週のものは計算除外
						// TODO:

						if (this._tradeInfo[i].type == 1) {
							// 買付
							tmpPrice += this._tradeInfo[i].price * this._tradeInfo[i].number;
							tmpCnt += this._tradeInfo[i].number;
						}

						print("${tmpCnt}:${tmpPrice}");
						this._tradeInfo[i].disp();
					}

					if (tmpPrice > 0) {
						tmpPrice = tmpPrice ~/ tmpCnt;
					}

					return (_historyItemSell(this._tradeInfo[index].price, this._tradeInfo[index].number, tmpPrice));
				}

				return (Padding());
			}
		);
		// セッティング画面
		_pageWidgets[2] = _createSettingsPage();
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
							"【購入】\n"
							"取得単価：${price} ベル\n"
							"約定数　：${count} カブ\n"
							"約定金額：${price * count} ベル\n"
							"購入日　：2020/05/17",
							style: TextStyle(
								color:Colors.lightGreen,
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
								"【売却】${(sellPrice - boughtPrice < 0) ? "＜損失発生＞" : "＜利益発生＞"}\n"
								"平均購入単価：${boughtPrice} ベル\n"
								"売却単価　　：${sellPrice} ベル\n"
								"約定数　　　：${sellCount} カブ\n"
								"約定金額　　：${sellPrice * sellCount} ベル\n"
								"損益計算　　：${(sellPrice - boughtPrice) > 0 ? "+" : "-"} ${((sellPrice - boughtPrice) * sellCount).abs()} ベル\n"
								"売却日　　　：2020/05/17",
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


	// ホーム画面
	Container _createHomePage() {
		return (new Container(
			child: Column(
					children: <Widget>[
						Container(
							padding: const EdgeInsets.all(2),
						),

						Column(
							// ボタンを横幅最大まで伸ばすため
							crossAxisAlignment: CrossAxisAlignment.stretch,

							children: <Widget>[
								_createHomePageButtonNowPrice(),
								_createHomePageButtonBuy(),
								_createHomePageButtonSell()
							]
						),

						_createHomePageCardNowPriceInfo(),
						_createHomePageCardStocksInfo()
					]
				)
			)
		);
	}


	RaisedButton _createHomePageButtonNowPrice() {
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
												if (_inputNowPrice.length == 0) {
													Fluttertoast.showToast(msg: "カブ価を入力してください。");
													return;
												}

												if (isNumeric(_inputNowPrice) == false) {
													Fluttertoast.showToast(msg: "カブ価に数値を入力してください");
													return;
												}

												int tmp = int.parse(_inputNowPrice);
												if (tmp <= 0) {
													if (_inputNowPrice.length == 0) {
														Fluttertoast.showToast(msg: "カブ価には0よりも大きい値を入力してください。");
														return;
													}
												}
												else {
													// 現在株価を更新
													setState(() {
														_nowPrice = tmp;
													});
												}

												Navigator.pop(context, 1);
												Fluttertoast.showToast(msg: "現在カブ価を更新しました。");
print(_nowPrice);
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
	RaisedButton _createHomePageButtonBuy() {
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
											labelText: "カブ価"
										),
										keyboardType: TextInputType.number,

										maxLength: 3,
										onChanged: (text) {
											if (text.length > 0) {
												_inputBuyPrice = text;
											}
										}
									),

									TextField(
										decoration: new InputDecoration(
											border: OutlineInputBorder(),
											labelText: "購入数"
										),
										keyboardType: TextInputType.number,

										maxLength: 5,
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
												if (_inputBuyPrice.length == 0) {
													Fluttertoast.showToast(msg: "カブ価を入力してください。");
													return;
												}
												else if (_inputBuyNumber.length == 0) {
													Fluttertoast.showToast(msg: "購入数を入力してください。");
													return;
												}

												if (isNumeric(_inputBuyPrice) == false) {
													Fluttertoast.showToast(msg: "カブ価に数値を入力してください");
													return;
												}
												else if (isNumeric(_inputBuyNumber) == false) {
													Fluttertoast.showToast(msg: "購入数に数値を入力してください");
													return;
												}

												Navigator.pop(context, 1);
												Fluttertoast.showToast(msg: "記帳しました。");
print(_inputBuyPrice + ":" + _inputBuyNumber);
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
	RaisedButton _createHomePageButtonSell() {
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
											labelText: "カブ価"
										),
										keyboardType: TextInputType.number,

										maxLength: 3,
										onChanged: (text){
											if (text.length > 0) {
												_inputSellPrice = text;
											}
										},
									),

									TextField(
										decoration: new InputDecoration(
											border: OutlineInputBorder(),
											labelText: "売却数"
										),
										keyboardType: TextInputType.number,

										maxLength: 5,
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
												if (_inputSellPrice.length == 0) {
													Fluttertoast.showToast(msg: "カブ価を入力してください。");
													return;
												}
												else if (_inputSellNumber.length == 0) {
													Fluttertoast.showToast(msg: "売却数を入力してください。");
													return;
												}

												if (isNumeric(_inputSellPrice) == false) {
													Fluttertoast.showToast(msg: "カブ価に数値を入力してください");
													return;
												}
												else if (isNumeric(_inputSellNumber) == false) {
													Fluttertoast.showToast(msg: "売却数に数値を入力してください");
													return;
												}

												Navigator.pop(context, 1);
												Fluttertoast.showToast(msg: "記帳しました。");
print(_inputSellPrice + ":" + _inputSellNumber);
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
	Column _createHomePageCardNowPriceInfo() {
		return (
			Column(children: [
				Builder(builder: (context) {
					return (
						Card(child: Column(
							children: <Widget>[
								ListTile(
									title:    Text("現在カブ価：${(this._nowPrice == 0 ? "【現在カブ価未記帳】" : this._nowPrice)}"),
									subtitle: Text("現在日付　：" + _systemTimeString)
								)
							])
						)
					);
				}),

				Card(child: Column(
					children: <Widget>[
						const ListTile(
							title:    Text("計算範囲"),
							subtitle: Text("2020/05/17-2020/05/23"),
						)
					])
				)
			])
		);
	}


	// 保有株式数などの情報表示カード
	Card _createHomePageCardStocksInfo() {
		return (
			Card(
				child: Column(children: [
					ListTile(
						title: Text("保有カブ数：${_possessionStockNum} カブ")
					),
					ListTile(
						title: Text("平均取得額：${_possessionStockAvePrice}　ベル")
					),
					ListTile(
						title: Text("評価損益額：")
					),
					ListTile(
						title: Text("利益率　　：")
					)
				])
			)
		);
	}


	// 設定ページ
	Container _createSettingsPage() {
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
												"あつまれどうぶつの森のゲーム内における、\n"
												"ベル稼ぎ手段のカブについて、\n"
												"購入時の金額などを忘れることを防止するため、\n"
												"本ソフトウェアは作成されました。\n"
												"\n"
												"ご自由にご活用くださいませ",
												style: new TextStyle(
													color: Colors.lightGreen,
													fontSize: 14.0
												)
											)
										)
									]
								)
							),

							Card(
								child: Column(
									children: [
										ListTile(
											title: Text("(c) jskny")
										)
									]
								),
							)
						]
					),
				]
			)
		));
	}

}

