import 'package:flutter_app/database.dart';
import 'package:flutter_app/models/account.dart';

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
