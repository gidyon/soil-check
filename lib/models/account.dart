class Account {
  String names;
  String phone;
  String language;

  Account({this.names, this.phone, this.language});

  Account.fromJson(Map<String, dynamic> json) {
    names = json['names'];
    phone = json['phone'];
    language = json['language'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['names'] = this.names;
    data['phone'] = this.phone;
    data['language'] = this.language;
    return data;
  }
}
