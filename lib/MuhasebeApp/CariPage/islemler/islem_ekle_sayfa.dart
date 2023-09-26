import 'package:flutter/material.dart';

/*My Libs*/
import 'package:muhasebe/MuhasebeApp/CariPage/Faturalar/faturalar.dart';
import 'package:muhasebe/MuhasebeApp/CariPage/islemler/islemler_sayfasi.dart';
import 'package:muhasebe/MuhasebeApp/Stok/malzemeler.dart';
import 'islemler.dart';
import '../Cari/user.dart';
import '../../CommonUsed/Functions.dart';

/*Others*/
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class IslemEkleSyf extends StatefulWidget {
  IslemEkleSyf(
      {super.key,
      required this.fatura,
      required this.faturaList,
      required this.musteri,
      required this.musteriler,
      required this.islemler});

  final List<User> musteriler;
  final Faturalar fatura;
  User musteri;
  List<Faturalar> faturaList;
  List<Islemler> islemler;
  @override
  State<IslemEkleSyf> createState() => _IslemEkleSyfState();
}

class _IslemEkleSyfState extends State<IslemEkleSyf> {
  List<AnaMalzemeler> AnaMalzemeList = [];
  List<ChildMalzemeler> ChildMalzemeList = [];
  List<Islemler> islemList = [];
  double kasaKgDouble = 2;
  double altToplam = 0;

  void LoadAnaMalzemeList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final malzemeStr = prefs.getString("AnaMalzemeler") ?? " ";
    setState(() {
      if (malzemeStr == " " || malzemeStr == "") {
        AnaMalzemeList = [];
      } else {
        AnaMalzemeList = AnaMalzemeler.decode(malzemeStr);
      }
    });
  }

  Future<void> SaveAnaMalzemeList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = AnaMalzemeler.encode(AnaMalzemeList);
    await prefs.setString("AnaMalzemeler", encodedData);
  }

  void LoadKasaKg() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      kasaKgDouble = prefs.getDouble("kasakg") ?? 2;
    });
  }

  void ChildMalzemeShow(AnaMalzemeler mal) {
    final child_str = mal.ChildMalzemeListString;
    setState(() {
      if (child_str == "") {
        ChildMalzemeList = [];
      } else {
        ChildMalzemeList = ChildMalzemeler.decode(child_str);
      }
    });
  }

  void DialogShower(content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: content,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  void SepeteEkleFunc(ChildMalzemeler child, index) {
    final kasaSayisi = KasaSayisiController.text.replaceAll(",", "").trim();
    final toplamKG = ToplamKgController.text.replaceAll(",", "").trim();
    final opFiyat = OpFiyatController.text.replaceAll(",", "").trim();

    if (int.tryParse(kasaSayisi) == null || double.tryParse(toplamKG) == null || (opFiyat != "" && double.tryParse(opFiyat) == null)) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'SAYI DEĞERLERİ HATALI',
        ),
      );
    } else if (double.parse(toplamKG) < 0 || int.parse(kasaSayisi) < 0) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'SAYI DEĞERLERİ NEGATİF OLAMAZ',
        ),
      );
    } else if (double.parse(toplamKG) -
            (int.parse(kasaSayisi) * kasaKgDouble) <=
        0) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'NET KG SIFIR veya NEGATİF OLAMAZ',
        ),
      );
    } 
    else if(opFiyat != "" && double.parse(opFiyat) <= 0)
    {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: '(OPSİYONEL) FİYAT NEGATİF OLAMAZ',
        ),
      );
    }
    else {
      double toplam_borc = 0;
      
      int kasa_sayisi = int.parse(kasaSayisi);
      double toplam_kg = double.parse(toplamKG);
      double net_kg = (toplam_kg - (kasa_sayisi * kasaKgDouble));
      
      if (opFiyat != "")
        toplam_borc = double.parse(opFiyat) * net_kg;
      else if (widget.fatura.gelir) 
        toplam_borc = child.satis_fiyat * net_kg;
      else 
        toplam_borc = child.alis_fiyat * net_kg;
      
      altToplam += toplam_borc;

      AnaMalzemeler malzeme = AnaMalzemeler("", 0, "");
      for (AnaMalzemeler a in AnaMalzemeList) {
        if (a.malzemeIsim == child.anaMalzeme) {
          malzeme = a;
        }
      }

      bool ayniMalzemeVar = false;
      setState(() {
        for (var islem in islemList) {
          if (islem.altMalzeme == child.childIsim &&
              islem.anaMalzeme == child.anaMalzeme) {
            ayniMalzemeVar = true;
            islem.netKg += net_kg;
            islem.kasaSayisi += kasa_sayisi;
            islem.toplam_borc =
                (toplam_borc + double.parse(islem.toplam_borc)).toString();
          }
        }

        if (!ayniMalzemeVar) {
          islemList.add(Islemler(toplam_borc.toString(), child.anaMalzeme,
              net_kg, kasa_sayisi, child.childIsim));
        }

        List<ChildMalzemeler> geciciChildMalzemeler =
            ChildMalzemeler.decode(malzeme.ChildMalzemeListString);
        if (widget.fatura.gelir) {
          malzeme.stokKG -= net_kg;
          geciciChildMalzemeler[index].stokKG -= net_kg;
          malzeme.ChildMalzemeListString =
              ChildMalzemeler.encode(geciciChildMalzemeler);
        } else {
          malzeme.stokKG += net_kg;
          geciciChildMalzemeler[index].stokKG += net_kg;
          malzeme.ChildMalzemeListString =
              ChildMalzemeler.encode(geciciChildMalzemeler);
        }

        ChildMalzemeShow(malzeme);

        Navigator.pop(context);
        ToplamKgController.clear();
        KasaSayisiController.clear();
        OpFiyatController.clear();
      });
    }
  }

  void SepettenSilFunc(i) {
    AnaMalzemeler malzeme = AnaMalzemeler("", 0, "");
    for (AnaMalzemeler mal in AnaMalzemeList) {
      if (islemList[i].anaMalzeme == mal.malzemeIsim) {
        malzeme = mal;
      }
    }

    List<ChildMalzemeler> geciciChildMalzemeler =
        ChildMalzemeler.decode(malzeme.ChildMalzemeListString);

    for (ChildMalzemeler child in geciciChildMalzemeler) {
      if (child.childIsim == islemList[i].altMalzeme) {
        if (widget.fatura.gelir) {
          malzeme.stokKG += islemList[i].netKg;
          child.stokKG += islemList[i].netKg;
          malzeme.ChildMalzemeListString =
              ChildMalzemeler.encode(geciciChildMalzemeler);
        } else {
          malzeme.stokKG -= islemList[i].netKg;
          child.stokKG -= islemList[i].netKg;
          malzeme.ChildMalzemeListString =
              ChildMalzemeler.encode(geciciChildMalzemeler);
        }
      }
    }
    altToplam -= double.parse(islemList[i].toplam_borc);
    islemList.removeAt(i);
    ChildMalzemeShow(malzeme);
  }

  void UpdateMusteriList() {
    double borc = 0;
    for (Faturalar fatura in widget.faturaList){
      if(fatura.gelir)
        borc += double.parse(fatura.toplamBorc);
      else
        borc -= double.parse(fatura.toplamBorc);
    }
    widget.musteri.kisi_borcu = borc;
    SaveMusteriList(widget.musteriler);
  }

  void IslemSepetiniOnayla() {
    if (islemList.length == 0) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'İşlem Sepetiniz Boş',
        ),
      );
    } else {
      bool ayniIslemVar = false;
      for (int i = 0; i < islemList.length; i++)
      {
        ayniIslemVar = false;
        for(Islemler islem in widget.islemler){
          if(islem.altMalzeme == islemList[i].altMalzeme && islem.anaMalzeme == islemList[i].anaMalzeme){
            ayniIslemVar = true;
            islem.netKg += islemList[i].netKg;
            islem.kasaSayisi += islemList[i].kasaSayisi;
            islem.toplam_borc = (double.parse(islemList[i].toplam_borc) + double.parse(islem.toplam_borc)).toString();
          }
        }
        if (!ayniIslemVar){
          widget.islemler.insert(0, islemList[i]);
        }
      }

      SaveIslemList(widget.fatura, widget.islemler);
      UpdateFaturaList();
      UpdateMusteriList();

      for(AnaMalzemeler ana in AnaMalzemeList){
        String childString = ana.ChildMalzemeListString;
        if (childString == "" || childString == " ")
          childString = "[]";
        List<ChildMalzemeler> gecici = ChildMalzemeler.decode(childString);
        for(ChildMalzemeler child in gecici){
          for (Islemler islem in islemList){
            if(islem.altMalzeme == child.childIsim && islem.anaMalzeme == child.anaMalzeme){
              List<HareketRaporu> hareketler = HareketRaporu.decode(child.hareketRaporu);
              if(widget.fatura.gelir)
                hareketler.insert(0, HareketRaporu("SATIS   -${islem.netKg}KG", DateTime.now().toString(), child.stokKG));
              else
                hareketler.insert(0, HareketRaporu("ALIS   +${islem.netKg}KG", DateTime.now().toString(), child.stokKG));

              child.hareketRaporu = HareketRaporu.encode(hareketler);
              ana.ChildMalzemeListString = ChildMalzemeler.encode(gecici);
            }
          }
        }
      }      
      SaveAnaMalzemeList();

      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: 'İşlem Sepetiniz Onaylandı',
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => IslemlerSayfasi(
                  fatura: widget.fatura,
                  faturaList: widget.faturaList,
                  musteri: widget.musteri,
                  musteriler: widget.musteriler,
                )),
      );
    }
  }

  var KasaSayisiController = TextEditingController();
  var ToplamKgController = TextEditingController();
  var OpFiyatController = TextEditingController();
  Widget SepeteEklePopUp(ChildMalzemeler child, index) {
    return StatefulBuilder(builder: (context, setStateSB) {
      return Container(
        padding: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * 0.33,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFieldForNumbers(KasaSayisiController, "Kasa Sayısı"),
            TextFieldForNumbers(ToplamKgController, "Toplam KG"),
            Row(children: [
              Expanded(child: Divider()),
              Text(
                "isteğe bağlı",
                style: TextStyle(color: Colors.black38, fontSize: 11),
              ),
              Expanded(child: Divider()),
            ]),
            TextFieldForNumbers(OpFiyatController, "Opsiyonel Fiyat"),
            ElevatedButton(
                onPressed: () {
                  SepeteEkleFunc(child, index);
                },
                child: Text("SEPETE EKLE"))
          ],
        ),
      );
    });
  }

  Widget TextFieldForNumbers(controller, label) {
    return TextField(
      controller: controller,
      maxLines: 1,
      maxLength: 10,
      inputFormatters: [
        ThousandsFormatter(allowFraction: true),
      ],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(8),
        isDense: true,
        labelText: label,
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black45,
          ),
        ),
      ),
    );
  }

  Widget IslemSepeti() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.3,
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 0),
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
                color: Colors.black,
              );
            },
            itemCount: islemList.length,
            itemBuilder: (_, i) {
              return ListTile(
                title: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${islemList[i].anaMalzeme} - ${islemList[i].altMalzeme}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                subtitle: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${islemList[i].netKg.toString().replaceAll(regex, '')}KG / ${islemList[i].kasaSayisi}Kasa / ${islemList[i].toplam_borc.replaceAll(regex, '')}TL",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        SepettenSilFunc(i);
                      });
                    },
                    icon: Icon(
                      Icons.delete_sweep,
                      color: Colors.pink,
                    )),
              );
            },
          ),
        ),
        Divider(height: 5, color: Colors.white,),
        Text("İŞLEM SEPETİ:       ${altToplam.toString().replaceAll(regex, '')}TL"),
      ],
    );
  }

  Widget AnaMalzemelerWidget() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          width: MediaQuery.of(context).size.width * 0.47,
          height: MediaQuery.of(context).size.height * 0.3,
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 0),
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
                color: Colors.black,
              );
            },
            itemCount: AnaMalzemeList.length,
            itemBuilder: (_, i) {
              return ListTile(
                onLongPress: () {
                  ChildMalzemeShow(AnaMalzemeList[i]);
                },
                title: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AnaMalzemeList[i].malzemeIsim,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                subtitle: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${AnaMalzemeList[i].stokKG.toString().replaceAll(regex, '')}KG",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              );
            },
          ),
        ),
        Text("ANA MALZEMELER"),
      ],
    );
  }

  Widget ChildMalzemelerWidget() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          width: MediaQuery.of(context).size.width * 0.47,
          height: MediaQuery.of(context).size.height * 0.3,
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 0),
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
                color: Colors.black,
              );
            },
            itemCount: ChildMalzemeList.length,
            itemBuilder: (_, i) {
              return ListTile(
                onLongPress: () {
                  DialogShower(SepeteEklePopUp(ChildMalzemeList[i], i));
                },
                title: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    ChildMalzemeList[i].childIsim,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                subtitle: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${ChildMalzemeList[i].stokKG.toString().replaceAll(regex, '')}KG",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ),
        Text("ALT MALZEMELER"),
      ],
    );
  }

  Future<void> UpdateFaturaList() async {
    double toplamBorc = 0;
    for (int i = 0; i < widget.islemler.length; i++) {
      toplamBorc += double.parse(widget.islemler[i].toplam_borc);
    }
    widget.fatura.toplamBorc = toplamBorc.toString();
    SaveFaturaList(widget.musteri, widget.faturaList);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LoadAnaMalzemeList();
    LoadKasaKg();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("İşlem Ekleme Sayfası"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(
              height: 10,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnaMalzemelerWidget(),
                ChildMalzemelerWidget(),
              ],
            ),
            Divider(
              height: 10,
              color: Colors.white,
            ),
            IslemSepeti(),
            Divider(
              height: 20,
              color: Colors.white,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    IslemSepetiniOnayla();
                  });
                },
                child: Text("İŞLEM SEPETİNİ TAMAMLA"))
          ],
        ),
      ),
    );
  }
}
