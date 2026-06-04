class User {
  final int id;
  final String fname;
  final String lname;
  final String username;
  final String phone;
  final String companyNid;
  final String companyName;

  User({
    required this.id,
    required this.fname,
    required this.lname,
    required this.username,
    required this.phone,
    required this.companyNid,
    required this.companyName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fname: json['fname'],
      lname: json['lname'],
      username: json['username'],
      phone: json['phone'],
      companyNid: json['company_nid'],
      companyName: json['companyName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fname': fname,
      'lname': lname,
      'username': username,
      'phone': phone,
      'company_nid': companyNid,
      'companyName':companyName
    };
  }

  @override
  int get hashCode => Object.hash(
        id,
        fname,
        lname,
        username,
        phone,
        companyNid,
        companyName,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.fname == fname &&
        other.lname == lname &&
        other.username == username &&
        other.phone == phone &&
        other.companyNid == companyNid &&
        other.companyName == companyName;
  }
}
