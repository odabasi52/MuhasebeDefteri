import 'dart:convert';

class Islemler{
  String toplam_borc;
  String anaMalzeme;
  String altMalzeme;
  int kasaSayisi;
  double netKg;
  

  Islemler(this.toplam_borc, this.anaMalzeme, this.netKg, this.kasaSayisi, this.altMalzeme);

  factory Islemler.fromJson(Map<String, dynamic> jsonData) {
    return Islemler(
      jsonData['toplam_borc'],
      jsonData['anaMalzeme'],
      jsonData['netKg'],
      jsonData['kasaSayisi'],   
      jsonData['altMalzeme'], 
    );
  }

  static Map<String, dynamic> toMap(Islemler islem) => {
        'toplam_borc': islem.toplam_borc,
        'anaMalzeme': islem.anaMalzeme,
        'netKg': islem.netKg,
        'kasaSayisi': islem.kasaSayisi,
        'altMalzeme': islem.altMalzeme,
      };

  static String encode(List<Islemler> islemler) => json.encode(
        islemler
            .map<Map<String, dynamic>>((islem) => Islemler.toMap(islem))
            .toList(),
      );

   static List<Islemler> decode(String islemler) =>
      (json.decode(islemler) as List<dynamic>)
          .map<Islemler>((item) => Islemler.fromJson(item))
          .toList();
}