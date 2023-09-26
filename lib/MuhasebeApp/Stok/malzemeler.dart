import 'dart:convert';

class AnaMalzemeler {
  String malzemeIsim;
  double stokKG;
  String ChildMalzemeListString;

  AnaMalzemeler(this.malzemeIsim, this.stokKG, this.ChildMalzemeListString);

  factory AnaMalzemeler.fromJson(Map<String, dynamic> jsonData) {
    return AnaMalzemeler(
      jsonData['malzemeIsim'],
      jsonData['stokKG'],
      jsonData['ChildMalzemeListString'],
    );
  }

  static Map<String, dynamic> toMap(AnaMalzemeler malzeme) => {
        'malzemeIsim': malzeme.malzemeIsim,
        'stokKG': malzeme.stokKG,
        'ChildMalzemeListString': malzeme.ChildMalzemeListString,
      };

  static String encode(List<AnaMalzemeler> malzemeler) => json.encode(
        malzemeler
            .map<Map<String, dynamic>>((malzeme) => AnaMalzemeler.toMap(malzeme))
            .toList(),
      );

  static List<AnaMalzemeler> decode(String malzemeler) =>
      (json.decode(malzemeler) as List<dynamic>)
          .map<AnaMalzemeler>((malzeme) => AnaMalzemeler.fromJson(malzeme))
          .toList();
}

class ChildMalzemeler {
  String childIsim;
  double stokKG;
  double alis_fiyat;
  double satis_fiyat;
  String anaMalzeme;
  String hareketRaporu;

  ChildMalzemeler(this.childIsim, this.stokKG, this.alis_fiyat, this.satis_fiyat, this.anaMalzeme, this.hareketRaporu);

  factory ChildMalzemeler.fromJson(Map<String, dynamic> jsonData) {
    return ChildMalzemeler(
      jsonData['childIsim'],
      jsonData['stokKG'],
      jsonData['alis_fiyat'],
      jsonData['satis_fiyat'],
      jsonData['anaMalzeme'],
      jsonData['hareketRaporu'],
    );
  }

  static Map<String, dynamic> toMap(ChildMalzemeler malzeme) => {
        'childIsim': malzeme.childIsim,
        'stokKG': malzeme.stokKG,
        'alis_fiyat': malzeme.alis_fiyat,
        'satis_fiyat': malzeme.satis_fiyat,
        'anaMalzeme': malzeme.anaMalzeme,
        'hareketRaporu': malzeme.hareketRaporu,
      };

  static String encode(List<ChildMalzemeler> malzemeler) => json.encode(
        malzemeler
            .map<Map<String, dynamic>>((malzeme) => ChildMalzemeler.toMap(malzeme))
            .toList(),
      );

  static List<ChildMalzemeler> decode(String malzemeler) =>
      (json.decode(malzemeler) as List<dynamic>)
          .map<ChildMalzemeler>((malzeme) => ChildMalzemeler.fromJson(malzeme))
          .toList();
}

class HareketRaporu{
    String rapor;
    String tarih;
    double anlikStok;

    HareketRaporu(this.rapor, this.tarih, this.anlikStok);

    factory HareketRaporu.fromJson(Map<String, dynamic> jsonData) {
    return HareketRaporu(
      jsonData['rapor'],
      jsonData['tarih'],
      jsonData['anlikStok'],
    );
  }

  static Map<String, dynamic> toMap(HareketRaporu malzeme) => {
        'rapor': malzeme.rapor,
        'tarih': malzeme.tarih,
        'anlikStok': malzeme.anlikStok,
      };

  static String encode(List<HareketRaporu> malzemeler) => json.encode(
        malzemeler
            .map<Map<String, dynamic>>((malzeme) => HareketRaporu.toMap(malzeme))
            .toList(),
      );

  static List<HareketRaporu> decode(String malzemeler) =>
      (json.decode(malzemeler) as List<dynamic>)
          .map<HareketRaporu>((malzeme) => HareketRaporu.fromJson(malzeme))
          .toList();
}