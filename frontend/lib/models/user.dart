class CustomUser {
  String name;
  String email;
  String password;

  CustomUser(this.name, this.email, this.password);

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  // Create object from JSON
  factory CustomUser.fromJson(Map<String, dynamic> json) {
    return CustomUser(
      json['name'],
      json['email'],
      json['password'],
    );
  }
}
