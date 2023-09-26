/*My Libs*/
import '../CariPage/Cari/user.dart';
import '../CariPage/Faturalar/faturalar.dart';
import '../CariPage/islemler/islemler.dart';

/*Others*/
import 'package:shared_preferences/shared_preferences.dart';



/*Save Function*/
Future<void> SaveMusteriList(List<User> musteriList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = User.encode(musteriList);
    await prefs.setString("musteriler", encodedData);
}
Future<void> SaveFaturaList(User musteri, List<Faturalar> faturaList) async {
    final String encodedData = Faturalar.encode(faturaList);
    musteri.faturaString = encodedData;
}
Future<void> SaveIslemList(Faturalar fatura, List<Islemler> islemList) async {
    final String encodedData = Islemler.encode(islemList);
    fatura.islemlerString = encodedData;
}

/*Adding comma to double values*/
String add_comma_to_double(input){
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String Function(Match) mathFunc = (Match match) => '${match[1]},';
  return input.toString().replaceAllMapped(reg, mathFunc);
}

/*Replace with turkish chars*/
String replacedString(String text) {
    return text
        .replaceAll(RegExp(r'ğ'), 'g')
        .replaceAll(RegExp(r'Ğ'), 'G')
        .replaceAll(RegExp(r'ö'), 'o')
        .replaceAll(RegExp(r'Ö'), 'O')
        .replaceAll(RegExp(r'ı'), 'i')
        .replaceAll(RegExp(r'İ'), 'I')
        .replaceAll(RegExp(r'ü'), 'u')
        .replaceAll(RegExp(r'Ü'), 'U')
        .replaceAll(RegExp(r'ş'), 's')
        .replaceAll(RegExp(r'Ş'), 'S')
        .replaceAll(RegExp(r'ç'), 'c')
        .replaceAll(RegExp(r'Ç'), 'C');
  }

  /*Regex to remove trailing 0s*/
  RegExp regex = RegExp(r'([.]*0)(?!.*\d)');