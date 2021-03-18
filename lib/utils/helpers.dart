class Utils {
  static getCode(String sms) {
    if (sms != null) {
      final intRegex = RegExp(r'\d+', multiLine: true);
      final code = intRegex.allMatches(sms).first.group(0);
      return code;
    }
    return "NO SMS";
  }

  static String formatPhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[^0-9]'), ""); // remove no digits
    phone = phone.replaceAll(RegExp(r'^0+'), ""); //remove ALL preceeding zeroes

    if (phone.startsWith("0") && phone.length == 10) {
      phone = phone.replaceFirst("0", "254");
    } else if (phone.startsWith("7") && phone.length == 9) {
      phone = "254" + phone;
    } else if (phone.startsWith("1") && phone.length == 9) {
      phone = "254" + phone;
    }
    return phone;
  }


  static String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  static String validateKRAPIN(String value) {
    String pattern = r'^[A]{1}[0-9]{9}[a-zA-Z]{1}$';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "KRA PIN is required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid KRA PIN";
    } else {
      return null;
    }
  }

  static String capitalize(String s) => (s != null && s.length > 1)
      ? s[0].toUpperCase() + s.substring(1)
      : s != null ? s.toUpperCase() : null;
}
