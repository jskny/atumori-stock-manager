/*
 * 処理として共通するものを集約
 * 2020/07/19
 * jskny
 */
 
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';


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


// 取引履歴
List<TradeInfo> tradeInfo = new List<TradeInfo>();
// 保有カブ数
int possessionStockNum = 0;
int possessionStockAvePrice = 0;


// 直近日曜日からの取引履歴をもとに、
// 保有カブ数、平均購入価格を算出する
void calcStockValues() {
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
	else {
		// 売却により所有数が0となっている場合は、平均取得価格に0をセット
		possessionStockNum = 0;
		possessionStockAvePrice = 0;
	}

	return;
}

