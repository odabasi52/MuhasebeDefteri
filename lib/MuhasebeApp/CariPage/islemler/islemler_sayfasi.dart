import 'package:flutter/material.dart';

/*My Libs*/
import 'package:muhasebe/MuhasebeApp/CariPage/Faturalar/faturalar.dart';
import 'islemler.dart';
import '../Cari/user.dart';
import '../../CommonUsed/Functions.dart';
import '../../Stok/malzemeler.dart';
import "islem_ekle_sayfa.dart";

/*Others*/
import 'package:shared_preferences/shared_preferences.dart';

class IslemlerSayfasi extends StatefulWidget {
  IslemlerSayfasi(
      {super.key,
      required this.fatura,
      required this.faturaList,
      required this.musteri,
      required this.musteriler});
  final List<User> musteriler;
  final Faturalar fatura;
  User musteri;
  List<Faturalar> faturaList;

  @override
  State<IslemlerSayfasi> createState() => _IslemlerSayfasiState();
}

class _IslemlerSayfasiState extends State<IslemlerSayfasi> {
  List<Islemler> islemlerList = [];
  List<AnaMalzemeler> AnaMalzemeList = [];

  void LoadIslemList() async {
    String islemString = widget.fatura.islemlerString;
    setState(() {
      if (islemString == " ") {
        islemlerList = [];
      } else {
        islemlerList = Islemler.decode(islemString);
      }
    });
  }

  Future<void> SaveAnaMalzemeList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = AnaMalzemeler.encode(AnaMalzemeList);
    await prefs.setString("AnaMalzemeler", encodedData);
  }

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

  Future<void> UpdateFaturaList() async {
    double toplamBorc = 0;
    for (int i = 0; i < islemlerList.length; i++) {
      toplamBorc += double.parse(islemlerList[i].toplam_borc);
    }
    widget.fatura.toplamBorc = toplamBorc.toString();
    SaveFaturaList(widget.musteri, widget.faturaList);
  }


  @override
  void initState() {
    super.initState();
    if (widget.fatura.islemlerString == " ") {
      islemlerList = [];
    } else {
      LoadIslemList();
      LoadAnaMalzemeList();
    }
  }

  void IslemSilmeFunc(i){
    AnaMalzemeler malzeme = AnaMalzemeler("", 0, "[]");
    
    for(AnaMalzemeler mal in AnaMalzemeList){
      if(mal.malzemeIsim == islemlerList[i].anaMalzeme){
        malzeme = mal;
      }
    }

    List<ChildMalzemeler> geciciChildMalzemeler =
            ChildMalzemeler.decode(malzeme.ChildMalzemeListString);

    for(ChildMalzemeler child in geciciChildMalzemeler){
      if(child.childIsim == islemlerList[i].altMalzeme){
        List<HareketRaporu> hareketler = HareketRaporu.decode(child.hareketRaporu);
        if (widget.fatura.gelir) {
          malzeme.stokKG += islemlerList[i].netKg;
          child.stokKG += islemlerList[i].netKg;
          hareketler.insert(0, HareketRaporu("(SİL) SATIŞ    +${islemlerList[i].netKg}KG", DateTime.now().toString(), child.stokKG));
          child.hareketRaporu = HareketRaporu.encode(hareketler);
          malzeme.ChildMalzemeListString =
              ChildMalzemeler.encode(geciciChildMalzemeler);
        } else {
          malzeme.stokKG -= islemlerList[i].netKg;
          child.stokKG -= islemlerList[i].netKg;
          hareketler.insert(0, HareketRaporu("(SİL) ALIŞ    -${islemlerList[i].netKg}KG", DateTime.now().toString(), child.stokKG));
          child.hareketRaporu = HareketRaporu.encode(hareketler);
          malzeme.ChildMalzemeListString =
              ChildMalzemeler.encode(geciciChildMalzemeler);
        }
      }
    }
    SaveAnaMalzemeList();

    double toplamBorc = double.parse(islemlerList[i].toplam_borc);
    islemlerList.removeAt(i);
    SaveIslemList(widget.fatura,islemlerList);
    widget.fatura.toplamBorc = (double.parse(widget.fatura.toplamBorc) - toplamBorc).toString();
    if (widget.fatura.gelir) {
      widget.musteri.kisi_borcu -= toplamBorc;
    } else {
      widget.musteri.kisi_borcu += toplamBorc;
    }
    SaveMusteriList(widget.musteriler);
    UpdateFaturaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Toplam İşlem Bedeli ${add_comma_to_double(widget.fatura.toplamBorc.replaceAll(regex, ''))}TL",
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
                MaterialPageRoute(builder: (context) => FaturaSayfasi(musteri: widget.musteri, musteriler: widget.musteriler)),
              );
          },
        ),
        title: Text(
          "Faturaya Ait İşlemler",
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => IslemEkleSyf(
                      musteri: widget.musteri,
                      musteriler: widget.musteriler,
                      fatura: widget.fatura,
                      faturaList: widget.faturaList,
                      islemler: islemlerList
                    )),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              LoadIslemList();
            });
          },
          child: ListView.builder(
            itemBuilder: (context, i) {
              return Card(
                margin: const EdgeInsets.all(4),
                elevation: 8,
                child: ListTile(
                  leading: Icon(
                    !widget.fatura.gelir
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    color: !widget.fatura.gelir ? Colors.red : Colors.green,
                  ),
                  title: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${islemlerList[i].anaMalzeme} - ${islemlerList[i].altMalzeme}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  subtitle: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${islemlerList[i].netKg.toString().replaceAll(regex, '')}KG / ${islemlerList[i].kasaSayisi}Kasa / ${islemlerList[i].toplam_borc.replaceAll(regex, '')}TL",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          IslemSilmeFunc(i);
                        });
                      },
                      icon: Icon(
                        Icons.delete_sweep,
                        color: Colors.pink,
                      )),
                ),
              );
            },
            itemCount: islemlerList.length,
          ),
        ),
      ),
    );
  }
}
