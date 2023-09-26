import 'package:flutter/material.dart';
import 'dart:convert';

/*My Libs*/
import 'user.dart';
import 'caripage.dart';
import '../../CommonUsed/CurvedAppBar.dart';
import '../../CommonUsed/Functions.dart';

/*Others*/
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import "package:flutter/services.dart";
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

class HesapCuzdan extends StatefulWidget {
  HesapCuzdan({super.key, required this.musteri, required this.musteriler});
  User musteri;
  final List<User> musteriler;

  @override
  State<HesapCuzdan> createState() => _HesapCuzdanState();
}

class _HesapCuzdanState extends State<HesapCuzdan> {
  List<Cuzdan> odemelerList = [];
  var OdenenFiyat = TextEditingController();

  void odemeEkle(text, eksildi, kart) {
    if (double.tryParse(text.replaceAll(',', "")) == null) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Lütfen sayı değerleri giriniz.',
        ),
      );
    } else if (double.parse(text.replaceAll(',', "")) <= 0) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Lütfen negatif değer girmeyiniz.',
        ),
      );
    }
    //PARA OKEYSE
    else {
      odemelerList.insert(
          0,
          Cuzdan(double.parse(text.replaceAll(',', "")),
              DateTime.now().toString(), eksildi, kart, null));
      if (eksildi) {
        widget.musteri.kisi_borcu -= double.parse(text.replaceAll(',', ""));
      } else {
        widget.musteri.kisi_borcu += double.parse(text.replaceAll(',', ""));
      }
      SaveCuzdanList();
      SaveMusteriList();
    }
  }

  Widget odemeTextField() {
    return Container(
      margin: const EdgeInsets.all(4),
      child: SizedBox(
        height: 45,
        width: double.infinity,
        child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsFormatter(allowFraction: true)],
          decoration: const InputDecoration(
            labelText: "Ödeme (TL)",
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black45,
              ),
            ),
          ),
          controller: OdenenFiyat,
        ),
      ),
    );
  }

  void LoadCuzdanList() async {
    final cuzdanString = widget.musteri.cuzdanString;
    setState(() {
      if (cuzdanString == " ") {
        odemelerList = [];
      } else {
        odemelerList = Cuzdan.decode(cuzdanString);
      }
    });
  }

  Future<void> SaveCuzdanList() async {
    final String encodedData = Cuzdan.encode(odemelerList);
    widget.musteri.cuzdanString = encodedData;
  }

  Future<void> SaveMusteriList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = User.encode(widget.musteriler);
    await prefs.setString("musteriler", encodedData);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.musteri.cuzdanString == " ") {
      odemelerList = [];
    } else {
      LoadCuzdanList();
    }
  }

  void removeCuzdan(index) {
    setState(() {
      if (odemelerList[index].eksildi) {
        widget.musteri.kisi_borcu += odemelerList[index].odenen;
      } else {
        widget.musteri.kisi_borcu -= odemelerList[index].odenen;
      }
      odemelerList.removeAt(index);
      SaveCuzdanList();
      SaveMusteriList();
    });
  }

  void showAllDialog(content) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: content,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        });
  }

  Widget deletePopUp(i) {
    return StatefulBuilder(builder: (context, setStateSB) {
      return Container(
        padding: const EdgeInsets.all(8),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () => setStateSB(() {
                      removeCuzdan(i);
                      Navigator.of(context).pop();
                    }),
                child: Text("SİL")),
            ElevatedButton(
                onPressed: () => setStateSB(() {
                      LoadCuzdanList();
                      Navigator.of(context).pop();
                    }),
                child: Text("İPTAL")),
          ],
        ),
      );
    });
  }

  Widget KartOrNakitPopUp(bool eksildi) {
    return StatefulBuilder(builder: (context, setStateSB) {
      return Container(
        padding: const EdgeInsets.all(8),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () => setStateSB(() {
                      odemeEkle(OdenenFiyat.text, eksildi, true);
                      Navigator.of(context).pop();
                      OdenenFiyat.clear();
                    }),
                child: Text("KART")),
            ElevatedButton(
                onPressed: () => setStateSB(() {
                      odemeEkle(OdenenFiyat.text, eksildi, false);
                      Navigator.of(context).pop();
                      OdenenFiyat.clear();
                    }),
                child: Text("NAKİT")),
          ],
        ),
      );
    });
  }

  void createPdf(i) async {
    final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final byteData = await rootBundle.load('assets/turkish.ttf');
    final ttf = pw.Font.ttf(byteData.buffer.asByteData());

    DateTime tarih = DateTime.parse(odemelerList[i].tarih);
    String odeme_tarihi =
        "${tarih.day.toString().padLeft(2, "0")}/${tarih.month.toString().padLeft(2, "0")}/${tarih.year.toString()}" +
            " - ${tarih.hour.toString().padLeft(2, "0")}.${tarih.minute.toString().padLeft(2, "0")}";

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("KISI ADI: " + widget.musteri.username,
                    style: pw.TextStyle(font: ttf)),
                pw.Text("KISI ID: " + widget.musteri.id,
                    style: pw.TextStyle(font: ttf)),
                pw.Text("BABA ADI: " + widget.musteri.baba_adi ,
                    style: pw.TextStyle(font: ttf)),
                pw.Text("ADRES: " + widget.musteri.adres,
                    style: pw.TextStyle(font: ttf)),
                pw.Text("TARIH: " + odeme_tarihi,
                    style: pw.TextStyle(font: ttf)),
                pw.Container(
                  height: 10,
                  color: PdfColors.white,
                ),
                pw.Header(
                  child: pw.Text("ODEME"),
                  margin: pw.EdgeInsets.symmetric(vertical: 3),
                ),
                pw.Container(
                  height: 10,
                  color: PdfColors.white,
                ),
                pw.Text(
                    (odemelerList[i].eksildi
                            ? "YAPILAN ÖDEME: "
                            : "ALINAN ÖDEME: ") +
                        odemelerList[i].odenen.toString().replaceAll(regex, "") +
                        "TL",
                    style: pw.TextStyle(font: ttf))
              ]);
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  String bakiye() {
    String bakiyev = widget.musteri.kisi_borcu >= 0
        ? widget.musteri.kisi_borcu.toString() + "TL BORÇ"
        : widget.musteri.kisi_borcu.toString() + "TL ALACAK";
    return bakiyev;
  }

  Widget PersonCard() {
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text('Müşteri adı:  ${widget.musteri.username}'),
      subtitle: Text(
        'TC No:  ${widget.musteri.id}\nTelefon:  ${widget.musteri.telefon}\nKişi Bakiyesi:  ${add_comma_to_double(bakiye().replaceAll("-", "")).replaceAll(regex, '')}',
      ),
    );
  }

  Widget tarih(i) {
    DateTime tarih = DateTime.parse(odemelerList[i].tarih);
    String odeme_tarihi = tarih.day.toString().padLeft(2, "0") +
        "/" +
        tarih.month.toString().padLeft(2, "0") +
        "/" +
        tarih.year.toString() +
        " - " +
        tarih.hour.toString().padLeft(2, "0") +
        ":" +
        tarih.minute.toString().padLeft(2, "0");

    return Text(odeme_tarihi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: BackButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CariPage()),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: BackgroundWaveClipper(),
              child: Container(
                padding: EdgeInsets.all(50),
                child: PersonCard(),
                width: MediaQuery.of(context).size.width,
                height: 225,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Color(0xFFFACCCC), Color(0xFFF6EFE9)],
                )),
              ),
            ),
            odemeTextField(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() {
                    showAllDialog(KartOrNakitPopUp(false));
                  }),
                  child: Text("ÖDEME YAP"),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    showAllDialog(KartOrNakitPopUp(true));
                  }),
                  child: Text("ÖDEME AL"),
                ),
              ],
            ),
            Container(
                height: 440,
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      if (widget.musteri.cuzdanString == " ") {
                        odemelerList = [];
                      } else {
                        LoadCuzdanList();
                      }
                    });
                  },
                  child: ListView.builder(
                    itemBuilder: (context, i) {
                      return Dismissible(
                        direction: DismissDirection.endToStart,
                        key: UniqueKey(),
                        onDismissed: (_) {
                          showAllDialog(deletePopUp(i));
                        },
                        child: Card(
                          margin: const EdgeInsets.all(4),
                          elevation: 8,
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(Icons.print,
                                  color: !odemelerList[i].eksildi
                                      ? Colors.red
                                      : Colors.green),
                              onPressed: () {
                                createPdf(i);
                              },
                            ),
                            title: Text(
                              (!odemelerList[i].eksildi
                                      ? "${add_comma_to_double(odemelerList[i].odenen).replaceAll(regex, '')}TL Ödeme Yapıldı "
                                      : "${add_comma_to_double(odemelerList[i].odenen).replaceAll(regex, '')}TL Ödeme Alındı ") +
                                  (odemelerList[i].kart ? "(KART)" : "(NAKİT)"),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                            subtitle: tarih(i),
                          ),
                        ),
                        background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            )),
                      );
                    },
                    itemCount: odemelerList.length,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

//Cuzdan OBJECT
class Cuzdan {
  final odenen;
  String tarih;
  bool eksildi;
  bool kart;
  String? odeme_disi;

  Cuzdan(this.odenen, this.tarih, this.eksildi, this.kart, this.odeme_disi);

  factory Cuzdan.fromJson(Map<String, dynamic> jsonData) {
    return Cuzdan(
      jsonData['odenen'],
      jsonData['tarih'],
      jsonData['eksildi'],
      jsonData['kart'],
      jsonData['odeme_disi'],
    );
  }

  static Map<String, dynamic> toMap(Cuzdan islem) => {
        'odenen': islem.odenen,
        'tarih': islem.tarih,
        'eksildi': islem.eksildi,
        'kart': islem.kart,
        'odeme_disi': islem.odeme_disi,
      };

  static String encode(List<Cuzdan> islemler) => json.encode(
        islemler
            .map<Map<String, dynamic>>((islem) => Cuzdan.toMap(islem))
            .toList(),
      );

  static List<Cuzdan> decode(String islemler) =>
      (json.decode(islemler) as List<dynamic>)
          .map<Cuzdan>((item) => Cuzdan.fromJson(item))
          .toList();
}
