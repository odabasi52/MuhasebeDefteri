import 'package:flutter/material.dart';
import 'package:muhasebe/MuhasebeApp/CariPage/Cari/caripage.dart';
import 'dart:convert';

/*My Libs*/
import 'package:muhasebe/MuhasebeApp/CariPage/islemler/islemler.dart';
import 'package:muhasebe/MuhasebeApp/CariPage/islemler/islemler_sayfasi.dart';
import '../Cari/hesapcuzdan.dart';
import '../Cari/user.dart';
import '../../CommonUsed/Functions.dart';

/*Others*/
import "package:flutter/services.dart";
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaturaSayfasi extends StatefulWidget {
  const FaturaSayfasi(
      {super.key, required this.musteri, required this.musteriler});
  final List<User> musteriler;
  final User musteri;

  @override
  State<FaturaSayfasi> createState() => _FaturaSayfasiState();
}

class _FaturaSayfasiState extends State<FaturaSayfasi> {
  List<Faturalar> faturaList = [];
  double kasaKgDouble = 2;

  void LoadKasaKg() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      kasaKgDouble = prefs.getDouble("kasakg") ?? 2;
    });
  }

  double getbrutkg(double netkg, double kasakg, int kasasayi) {
    double darakg = kasakg * (kasasayi.toDouble());
    double brutkg = netkg + darakg;
    return brutkg;
  }

  String createPdfStringSubTotal(i) {
    String stfatura = "";
    try {
      List<Islemler> islemler = Islemler.decode(faturaList[i].islemlerString);
      if (islemler.length > 0) {
        double toplamnet = 0;
        double toplambrut = 0;
        int toplamkasa = 0;
        double toplamborc = 0;
        for (int i = 0; i < islemler.length; i++) {
          toplamnet += islemler[i].netKg;
          toplamkasa += islemler[i].kasaSayisi;
          toplamborc += double.parse(islemler[i].toplam_borc);
        }
        toplambrut = (toplamnet + (kasaKgDouble * toplamkasa));
        stfatura =
            "Brüt: ${toplambrut.toString().replaceAll(regex, '')}KG - Net: ${toplamnet.toString().replaceAll(regex, '')}KG - $toplamkasa KASA - ${toplamborc.toString().replaceAll(regex, '')}TL";
      }
    } catch (er) {
      stfatura = "ALT TOPLAM HESAPLANAMADI";
    }
    return stfatura;
  }

  List<pw.Widget> buildPoints(int i, ttf) {
    List<pw.Widget> bullets = [];
    List<Islemler> islemler = Islemler.decode(faturaList[i].islemlerString);
    try {
      if (islemler.length > 0) {
        for (int i = 0; i < islemler.length; i++) {
          String birim_fatura =
              "${islemler[i].anaMalzeme}/${islemler[i].altMalzeme}" +
                  " - " +
                  "Brüt " +
                  getbrutkg(islemler[i].netKg, kasaKgDouble,
                          islemler[i].kasaSayisi)
                      .toString()
                      .replaceAll(regex, '') +
                  "KG" +
                  " - " +
                  "Net " +
                  islemler[i].netKg.toString().replaceAll(regex, '') +
                  "KG - " +
                  islemler[i].kasaSayisi.toString() +
                  " KASA - " +
                  islemler[i].toplam_borc.replaceAll(regex, '') +
                  "TL\n";
          bullets.add(pw.Bullet(
              text: birim_fatura,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.normal, font: ttf)));
        }
      }
    } catch (_) {
      bullets.add(pw.Bullet(
        text: "FATURANIZDA ISLEM BULUNMAMAKTADIR.",
      ));
    }
    return (bullets);
  }

  void createPdf(i) async {
    final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final byteData = await rootBundle.load('assets/turkish.ttf');
    final ttf = pw.Font.ttf(byteData.buffer.asByteData());

    DateTime tarih = DateTime.parse(faturaList[i].fatura_tarihi);
    String fatura_tarihi =
        "${tarih.day.toString().padLeft(2, "0")}/${tarih.month.toString().padLeft(2, "0")}/${tarih.year.toString()}" +
            " - ${tarih.hour.toString().padLeft(2, "0")}.${tarih.minute.toString().padLeft(2, "0")}";

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => <pw.Widget>[
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text("KISI ADI: " + widget.musteri.username,
                  style: pw.TextStyle(font: ttf)),
              pw.Text("KISI ID: " + widget.musteri.id + "\n",
                  style: pw.TextStyle(font: ttf)),
              pw.Text("BABA ADI: " + widget.musteri.baba_adi + "\n",
                  style: pw.TextStyle(font: ttf)),
              pw.Text("ADRES: " + widget.musteri.adres + "\n",
                  style: pw.TextStyle(font: ttf)),
              pw.Text("TARIH: " + fatura_tarihi,
                  style: pw.TextStyle(font: ttf)),
              pw.Container(
                height: 10,
                color: PdfColors.white,
              ),
              pw.Header(
                child: pw.Text("FATURA"),
                margin: pw.EdgeInsets.symmetric(vertical: 3),
              ),
              pw.Container(
                height: 10,
                color: PdfColors.white,
              ),
              ...buildPoints(i, ttf),
            ],
          ),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                child: pw.Text("ALT TOPLAM"),
                margin: pw.EdgeInsets.symmetric(vertical: 3),
              ),
              pw.Text(createPdfStringSubTotal(i),
                  style: pw.TextStyle(font: ttf)),
            ],
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  void removeFatura(index) {
    setState(() {
      if (faturaList[index].gelir) {
        widget.musteri.kisi_borcu -= double.parse(faturaList[index].toplamBorc);
      } else {
        widget.musteri.kisi_borcu -=
            -double.parse(faturaList[index].toplamBorc);
      }

      faturaList.removeAt(index);
      SaveFaturaList(widget.musteri, faturaList);
      SaveMusteriList(widget.musteriler);
    });
  }

  void LoadFaturaList() async {
    final faturaString = widget.musteri.faturaString;
    setState(() {
      if (widget.musteri.faturaString == " ") {
        faturaList = [];
      } else {
        faturaList = Faturalar.decode(faturaString);
      }
    });
  }

  //0.0 olan faturaları otomatik sil
  void remove0Faturas() {
    List<Faturalar> toRemoveList = [];

    faturaList.forEach((fatura) {
      if (fatura.toplamBorc == "0.0") {
        toRemoveList.add(fatura);
      }
    });

    faturaList.removeWhere((element) => toRemoveList.contains(element));
    SaveFaturaList(widget.musteri, faturaList);
    SaveMusteriList(widget.musteriler);
  }

  @override
  void initState() {
    super.initState();
    LoadFaturaList();
    LoadKasaKg();
    remove0Faturas();
  }

  void showFaturaDialog(content) {
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

  Widget FaturaPopUp() {
    return StatefulBuilder(builder: (context, setStateSB) {
      return Container(
        padding: const EdgeInsets.all(8),
        height: 83,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  "SATIŞ FATURASI",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                IconButton(
                    onPressed: () => setStateSB(() {
                          bool gelir = true;
                          addFatura(gelir, context);
                        }),
                    icon: Icon(
                      Icons.post_add,
                      color: Colors.green,
                    )),
              ],
            ),
            Column(
              children: [
                Text(
                  "ALIŞ FATURASI",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                IconButton(
                    onPressed: () => setStateSB(() {
                          bool gelir = false;
                          addFatura(gelir, context);
                        }),
                    icon: Icon(
                      Icons.post_add,
                      color: Colors.red,
                    )),
              ],
            ),
          ],
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
                      removeFatura(i);
                      Navigator.of(context).pop();
                    }),
                child: Text("SİL")),
            ElevatedButton(
                onPressed: () => setStateSB(() {
                      LoadFaturaList();
                      Navigator.of(context).pop();
                    }),
                child: Text("İPTAL")),
          ],
        ),
      );
    });
  }

  void addFatura(gelir, contxt) {
    // ignore: prefer_interpolation_to_compose_strings
    final fatura =
        Faturalar(" ", DateTime.now().toString(), gelir, "0.0", null);

    setState(() {
      faturaList.insert(0, fatura);
      SaveFaturaList(widget.musteri, faturaList);
      SaveMusteriList(widget.musteriler);
    });

    Navigator.of(contxt).pop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IslemlerSayfasi(
          fatura: faturaList[0],
          faturaList: faturaList,
          musteri: widget.musteri,
          musteriler: widget.musteriler,
        ),
      ),
    );
  }

  Widget tarih(i) {
    DateTime tarih = DateTime.parse(faturaList[i].fatura_tarihi);
    String fatura_tarihi = tarih.day.toString().padLeft(2, "0") +
        "/" +
        tarih.month.toString().padLeft(2, "0") +
        "/" +
        tarih.year.toString() +
        " - " +
        tarih.hour.toString().padLeft(2, "0") +
        ":" +
        tarih.minute.toString().padLeft(2, "0");
    return Text(fatura_tarihi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.musteri.kisi_borcu < 0
                ? "${widget.musteri.username}   ${add_comma_to_double(-widget.musteri.kisi_borcu).replaceAll(regex, '')}TL Alacaklı"
                : "${widget.musteri.username}   ${add_comma_to_double(widget.musteri.kisi_borcu).replaceAll(regex, '')}TL Borçlu",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_sharp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CariPage()),
              );
            },
          ),
          title: const Text("Kişiye Ait Faturalar"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HesapCuzdan(
                      musteri: widget.musteri,
                      musteriler: widget.musteriler,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.account_balance_wallet),
            )
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          showFaturaDialog(FaturaPopUp());
        }),
        child: const Icon(Icons.post_add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            LoadFaturaList();
            remove0Faturas();
          });
        },
        child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: ListView.builder(
              itemBuilder: (context, i) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    if (double.parse(faturaList[i].toplamBorc) == 0) {
                      showFaturaDialog(deletePopUp(i));
                    } else {
                      showTopSnackBar(
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          message:
                              'Fatura İçerisindeki İşlemleri Silmeden Faturayı Silemezsiniz',
                        ),
                      );
                      LoadFaturaList();
                    }
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(4),
                    elevation: 8,
                    child: ListTile(
                      leading: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.print,
                              color: faturaList[i].gelir
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            onPressed: () {
                              createPdf(i);
                            },
                          ),
                        ],
                      ),
                      title: Text(add_comma_to_double(
                              faturaList[i].toplamBorc.replaceAll(regex, '')) +
                          "₺"),
                      subtitle: tarih(i),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.receipt,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () => setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IslemlerSayfasi(
                                fatura: faturaList[i],
                                faturaList: faturaList,
                                musteri: widget.musteri,
                                musteriler: widget.musteriler,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
              itemCount: faturaList.length,
            )),
      ),
    );
  }
}

class Faturalar {
  String islemlerString;
  String fatura_tarihi;
  String toplamBorc;
  bool gelir;
  User? kisi;

  Faturalar(this.islemlerString, this.fatura_tarihi, this.gelir,
      this.toplamBorc, this.kisi);

  factory Faturalar.fromJson(Map<String, dynamic> jsonData) {
    return Faturalar(
      jsonData['islemlerString'],
      jsonData['fatura_tarihi'],
      jsonData['gelir'],
      jsonData['toplamBorc'],
      jsonData['kisi'],
    );
  }

  static Map<String, dynamic> toMap(Faturalar fatura) => {
        'islemlerString': fatura.islemlerString,
        'fatura_tarihi': fatura.fatura_tarihi,
        'gelir': fatura.gelir,
        'toplamBorc': fatura.toplamBorc,
        'kisi': fatura.kisi,
      };

  static String encode(List<Faturalar> faturalar) => json.encode(
        faturalar
            .map<Map<String, dynamic>>((item) => Faturalar.toMap(item))
            .toList(),
      );

  static List<Faturalar> decode(String faturalar) =>
      (json.decode(faturalar) as List<dynamic>)
          .map<Faturalar>((item) => Faturalar.fromJson(item))
          .toList();
}
