/*
 * 処理として共通するものを集約
 * 2020/07/19
 * jskny
 */

import 'dart:async';
import 'dart:ffi';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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


	// データベースから読み込んだ値で登録する時用
	TradeInfo.fillByDatabase(int t, int p, int n, String dStr) {
		this.type = t;
		this.price = p;
		this.number = n;

		this.setDate(dStr);
	}


	// 日付・時刻につき再計算
	void setDate(String tStr) {
		DateFormat fmt = DateFormat('yyyy/MM/dd');
		this.date = fmt.parse(tStr);
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


// DBと接続
void connectDatabase() async {
print("[DB CONNECT START]");
try {
	final t_db = await openDatabase(
		join(await getDatabasesPath(), 'database.db'),
		version: 1,
		onCreate: (Database db, int version) async {
			// 取引ログテーブル（LOGDAT）が存在しない場合に、新規作成する
			//https://cha-shu00.hatenablog.com/entry/2017/10/11/091751
			String tSql = 
				"CREATE TABLE IF NOT EXISTS LOGDAT ("
					"ID INTEGER PRIMARY KEY,"
					"TYPE INTEGER,"
					"PRICE INTEGER,"
					"NUMBER INTEGER,"
					"DATESTR TEXT"
				")";

print(tSql);
			await db.execute(tSql);
		}
	);

//	await t_db.close();
}
catch (e) {
	print(e);
}
print("[DB CONNECT END]");
	return;
}


// データベースから取引ログを読み込み
// 取引履歴を構築
bool g_flagIsDbLoaded = false;

void loadDatabase() async {
	if (g_flagIsDbLoaded) {
		// 初期起動時に読み込みが完了しているならば、
		// 2度読み込みは行わない。
print("[LOAD] error db has already loaded.");
		return;
	}

	final t_db = await openDatabase(
		join(await getDatabasesPath(), 'database.db'),
		version: 1,
		onCreate: (Database db, int version) async {
			// 取引ログテーブル（LOGDAT）が存在しない場合に、新規作成する
			//https://cha-shu00.hatenablog.com/entry/2017/10/11/091751
			String tSql = 
				"CREATE TABLE IF NOT EXISTS LOGDAT ("
					"ID INTEGER PRIMARY KEY,"
					"TYPE INTEGER,"
					"PRICE INTEGER,"
					"NUMBER INTEGER,"
					"DATESTR TEXT"
				")";

print(tSql);
			await db.execute(tSql);
		}
	);

	String tSql =
		"SELECT * FROM LOGDAT "
		"ORDER BY ID ASC";

	// SQL実行
	List<Map> result = await t_db.rawQuery(tSql);

print("[DB LOAD START]");
	// 実行結果から取引履歴を構築
	for (Map item in result) {
		TradeInfo t = new TradeInfo.fillByDatabase(
			int.parse(item['TYPE'].toString()),
			item['PRICE'],
			item['NUMBER'],
			item['DATESTR']);

			// 取引ログに追加
			tradeInfo.add(t);
print(t.toString());
	}

	g_flagIsDbLoaded = true;
//	await t_db.close();
print("[DB LOAD END]");
}


// 取引記録をデータベースに追加
void addDatabase(TradeInfo t) async {
print("[DB INSERT START]");
	final t_db = await openDatabase(
		join(await getDatabasesPath(), 'database.db'),
		version: 1,
		onCreate: (Database db, int version) async {
			// 取引ログテーブル（LOGDAT）が存在しない場合に、新規作成する
			//https://cha-shu00.hatenablog.com/entry/2017/10/11/091751
			String tSql = 
				"CREATE TABLE IF NOT EXISTS LOGDAT ("
					"ID INTEGER PRIMARY KEY,"
					"TYPE INTEGER,"
					"PRICE INTEGER,"
					"NUMBER INTEGER,"
					"DATESTR TEXT"
				")";

print(tSql);
			await db.execute(tSql);
		}
	);


	String tSql =
		"INSERT INTO LOGDAT(ID, TYPE, PRICE, NUMBER, DATESTR) "
		"VALUES(${tradeInfo.length}, ${t.type}, ${t.price}, ${t.number}, '${t.dateString}')";

print(tSql);
	await t_db.transaction((txn) async {
		int id = await txn.rawInsert(tSql);
		print("insert : $id");
	});

//	await t_db.close();
print("[DB INSERT END]");
	return;
}

