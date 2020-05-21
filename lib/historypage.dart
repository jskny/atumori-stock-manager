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


class PageWidgetOfHistoryState extends State<PageWidgetOfHistory> {
 	// 取引履歴
	List<TradeInfo> _tradeInfo = new List<TradeInfo>();

	// 保有カブ数
	int _possessionStockNum = 0;
	int _possessionStockAvePrice = 0;


	@override
	void initState() {
		super.initState();

		// 買付ダミー
		this._tradeInfo.add(new TradeInfo.fill(1, 50, 150));
		this._tradeInfo.add(new TradeInfo.fill(1, 15, 50));

		// 売却ダミー
		this._tradeInfo.add(new TradeInfo.fill(2, 35, 200));
		this._tradeInfo.add(new TradeInfo.fill(2, 30, 120));


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
				)
			)
		);
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
}
