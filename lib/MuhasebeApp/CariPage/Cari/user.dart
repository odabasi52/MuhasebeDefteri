import 'dart:convert';

class User{
  final String username;
  final String id;
  final String baba_adi;
  final String telefon;
  final String adres;
  double kisi_borcu;
  String faturaString;
  String cuzdanString;

  User(this.username, this.id,  this.baba_adi, this.telefon, this.adres, this.faturaString, this.kisi_borcu, this.cuzdanString);

  factory User.fromJson(Map<String, dynamic> jsonData) {
    return User(
      jsonData['username'],
      jsonData['id'],
      jsonData['baba_adi'],
      jsonData['telefon'],
      jsonData['adres'],
      jsonData['faturaString'],
      jsonData['kisi_borcu'],
      jsonData['cuzdanString'],
    );
  }

  static Map<String, dynamic> toMap(User user) => {
        'username': user.username,
        'id': user.id,
        'baba_adi': user.baba_adi,
        'telefon': user.telefon,
        'adres': user.adres,
        'faturaString':user.faturaString,
        'kisi_borcu': user.kisi_borcu,
        'cuzdanString':user.cuzdanString
      };

  static String encode(List<User> users) => json.encode(
        users
            .map<Map<String, dynamic>>((user) => User.toMap(user))
            .toList(),
      );

   static List<User> decode(String users) =>
      (json.decode(users) as List<dynamic>)
          .map<User>((item) => User.fromJson(item))
          .toList();
}