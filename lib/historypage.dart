/*
 * あつもり
 * カブ価メモ君
 *
 * 取引履歴モジュール
 *
 * 2020/02/51
 * jskny
 */

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'homepage.dart';


// 取引ログ格納用構造体
class TradeInfo {
	// 取引区分（０＝未指定、１＝買付、２＝売却）
	int type;

	// 取引単価
	int price;

	// 取引個数
	int number;

	// 処理日付等
	DateTime date;
	String dateString;

	// 初期化だけをするコンストラクタ
	TradeInfo() : 
		this.type = 0,
		this.price = 0,
		this.number = 0,
		this.date = null,
		this.dateString ="";


	// 取引区分、単価価格、数量
	TradeInfo.fill(int t, int p, int n) {
		this.type = t;
		this.price = p;
		this.number = n;

		// 新規登録時の仕入れ日につき、直近日曜日
		if (t == 1) {
			// 買付は直近日曜日
			this.date = getLastSundayDataTime();
		}
		else {
			initializeDateFormatting('ja');
			this.date = DateTime.now();
		}

		this.dateString = DateFormat('yyyy/MM/dd').format(this.date).toString();
	}


	// 表示
	@override
	String toString() {
		// 取引区分：単価：個数
		// Buy, Sell, Null
		return ("${this.type == 1 ? "B" : (this.type == 2 ? "S" : "N") }, ${this.price}, ${this.number}");
	}
}


class _InheritedWidgetForPageOfHistory extends InheritedWidget {
	_InheritedWidgetForPageOfHistory({
	Key key,
	@required Widget child,
	@required this.data,
	}) : super(key: key, child: child);

	final PageWidgetOfHistory data;

	@override
	bool updateShouldNotify(_InheritedWidgetForPageOfHistory oldWidget) {
		return true;
	}
}


class PageWidgetOfHistory extends StatefulWidget {
	PageWidgetOfHistory({
		Key key,
		this.child,
	}) : super(key: key);

	final Widget child;

	@override
	PageWidgetOfHistoryState createState() => PageWidgetOfHistoryState();

	static PageWidgetOfHistory of(BuildContext context, {bool rebuild = true}) {
		if (rebuild) {
			return (context.dependOnInheritedWidgetOfExactType<_InheritedWidgetForPageOfHistory>().data);
		}

		return (context.findAncestorWidgetOfExactType<_InheritedWidgetForPageOfHistory>().data);
	}
}


// 取引履歴
List<TradeInfo> tradeInfo = new List<TradeInfo>();
// 保有カブ数
int possessionStockNum = 0;
int possessionStockAvePrice = 0;


// 直近日曜日からの取引履歴をもとに、
// 保有カブ数、平均購入価格を算出する
void CalcStockValues() {
	possessionStockNum = 0;
	possessionStockAvePrice = 0;

	// 保有株式数等計算
	for (int i = 0; i < tradeInfo.length; ++i) {
		// 日付が先週のものは計算除外
		Duration dur =  tradeInfo[i].date.difference(getLastSundayDataTime());
		if ((dur.inDays).floor() > 6) {
			continue;
		}

		if (tradeInfo[i].type == 1) {
			// 買付
			possessionStockAvePrice += tradeInfo[i].price * tradeInfo[i].number;
			possessionStockNum += tradeInfo[i].number;
		}
	}

	if (possessionStockNum > 0) {
		possessionStockAvePrice = possessionStockAvePrice ~/ possessionStockNum;
	}

	return;
}


class PageWidgetOfHistoryState extends State<PageWidgetOfHistory> {
	@override
	void initState() {
		super.initState();

		// 買付ダミー
		tradeInfo.add(new TradeInfo.fill(1, 50, 150));
		tradeInfo.add(new TradeInfo.fill(1, 15, 50));

		// 売却ダミー
		tradeInfo.add(new TradeInfo.fill(2, 35, 200));
		tradeInfo.add(new TradeInfo.fill(2, 30, 120));

		CalcStockValues();
	}

	@override
	Widget build(BuildContext context) {
		return (_createHistoryPage(context));
	}


	// 取引履歴画面
	Container _createHistoryPage(BuildContext context) {
		return (
			Container(
				child: ListView.builder(
					itemCount: tradeInfo.length,
					itemBuilder: (context, int index) {
						// 買付の場合
						if (tradeInfo[index].type == 1) {
							return (_historyItemBought(
									tradeInfo[index].price,
									tradeInfo[index].number,
									tradeInfo[index].dateString
								)
							);
						}
						// 売却の場合
						else if (tradeInfo[index].type == 2) {
							// 平均取得価格等を再計算
							CalcStockValues();
							return (_historyItemSell(tradeInfo[index].price, tradeInfo[index].number, possessionStockAvePrice, tradeInfo[index].dateString));
						}

						return (Padding(
							padding: EdgeInsets.all(0)
						));
					}
				)
			)
		);
	}

 
	// 取引記録（購入）のオブジェクト
	Widget _historyItemBought(int price, int count, String date) {
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
							"購入日　：${date}",
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
	Widget _historyItemSell(int sellPrice, int sellCount, int boughtPrice, String date) {
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
								"売却日　　　：${date}",
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
}
