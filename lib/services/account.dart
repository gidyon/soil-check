import 'package:flutter_app/database.dart';
import 'package:flutter_app/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

const accountsTable = "Account";

class AccountServiceSQLite {
  static Future<Account> getAccount() async {
    final db = await DBProvider.db.database;
    var result = await db.query(accountsTable, limit: 1);

    print('getting account result');
    print(result);

    if (!result.isNotEmpty) return Account();

    print('result not empty');

    var jsonData = result[0];
    var res = Account.fromJson(jsonData);

    print(res);

    return res;
  }

  static Future<void> setAccount(Account account) async {
    final db = await DBProvider.db.database;
    // Delete existing accounts
    await db.rawDelete("Delete from $accountsTable");
    // Add the user
    await db.insert(accountsTable, account.toJson());
  }
}

class AccountServiceV2 {
  static Future<Account> getAccount() async {
    var sp = await SharedPreferences.getInstance();
    var names = sp.getString("names");
    var phone = sp.getString("phone");
    var language = sp.getString("language");

    var res = Account(
        language: language ?? '', names: names ?? '', phone: phone ?? '');

    return res;
  }

  static Future<void> setAccount(Account account) async {
    var sp = await SharedPreferences.getInstance();
    sp.setString("names", account.names);
    sp.setString("phone", account.phone);
    sp.setString("language", account.language);
  }
}
