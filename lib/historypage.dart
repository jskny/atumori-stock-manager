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

import "common.dart";


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
	@override
	void initState() {
		super.initState();

		calcStockValues();
	}

	@override
	Widget build(BuildContext context) {
		return (_createHistoryPage(context));
	}


	// 取引履歴画面
	Container _createHistoryPage(BuildContext context) {
		if (tradeInfo.length == 0) {
			return (
				Container(
					child: ListView(
						children: <Widget>[
							Card(
								child: Column(
								children: [
									ListTile(
										title: Text(
											"取引履歴がありません",
											style: new TextStyle(
												color: Colors.white,
												fontSize: 16.0
											)
										)
									)
								])
							)
						])
					)
				);
		}

		return (
			Container(
				child: ListView.builder(
					itemCount: tradeInfo.length,
					itemBuilder: (context, int index) {
						// 新しいものから古いものを表示する
						int tIndex = (tradeInfo.length-1) - index;

						// 買付の場合
						if (tradeInfo[tIndex].type == 1) {
							return (_historyItemBought(
									tradeInfo[index].price,
									tradeInfo[tIndex].number,
									tradeInfo[tIndex].dateString
								)
							);
						}
						// 売却の場合
						else if (tradeInfo[tIndex].type == 2) {
							// 平均取得価格等を再計算
							calcStockValues();
							return (_historyItemSell(tradeInfo[tIndex].price, tradeInfo[tIndex].number, possessionStockAvePrice, tradeInfo[tIndex].dateString));
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
