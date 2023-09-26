import 'package:flutter/material.dart';

/*My Libs*/
import 'malzeme_ayarlar_main.dart';
import 'malzemeler.dart';
import '../CommonUsed/CurvedAppBar.dart';
import '../CommonUsed/Functions.dart';
import '../mainpage.dart';
import 'stokhareketraporu.dart';

/*Others*/
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  List<AnaMalzemeler> AnaMalzemeList = [];
  List<ChildMalzemeler> ChildMalzemeList = [];

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LoadAnaMalzemeList();
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

  Widget AnaMalzemelerWidget() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          width: MediaQuery.of(context).size.width * 0.47,
          height: MediaQuery.of(context).size.height * 0.55,
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
                    "${add_comma_to_double(AnaMalzemeList[i].stokKG).replaceAll(regex, '')}KG",
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

  void EkstraEkleFunc(bool eksiStok, ChildMalzemeler malzeme) {
    final kg_s = KGController.text.trim().replaceAll(",", "");
    final aciklama_s = AciklamaController.text.trim().toUpperCase();
    if (kg_s == "" || aciklama_s == "") {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Alanları Doldurunuz',
        ),
      );
    } else if (double.tryParse(kg_s) == null) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Sayı Değeri Giriniz',
        ),
      );
    } else if (double.parse(kg_s) <= 0) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'KG Negatif Olamaz',
        ),
      );
    } else {
      Navigator.pop(context);
      double stok = double.parse(kg_s);

      AnaMalzemeler ana = AnaMalzemeler("", 0, "[]");
      for (AnaMalzemeler a in AnaMalzemeList) {
        if (a.malzemeIsim == malzeme.anaMalzeme) {
          ana = a;
        }
      }
      List<ChildMalzemeler> gecici =
          ChildMalzemeler.decode(ana.ChildMalzemeListString);
      List<HareketRaporu> hareketler = [];
      for (ChildMalzemeler c in gecici) {
        if (c.anaMalzeme == malzeme.anaMalzeme &&
            c.childIsim == malzeme.childIsim) {
          hareketler = HareketRaporu.decode(c.hareketRaporu);
          if (eksiStok) {
            c.stokKG -= stok;
            ana.stokKG -= stok;
            hareketler.insert(
                0,
                HareketRaporu("${aciklama_s}    -${stok}",
                    DateTime.now().toString(), c.stokKG));
          } else {
            c.stokKG += stok;
            ana.stokKG += stok;
            hareketler.insert(
                0,
                HareketRaporu("${aciklama_s}    +${stok}",
                    DateTime.now().toString(), c.stokKG));
          }
          c.hareketRaporu = HareketRaporu.encode(hareketler);
          break;
        }
      }
      setState(() {
        ana.ChildMalzemeListString = ChildMalzemeler.encode(gecici);
        SaveAnaMalzemeList();
        ChildMalzemeShow(ana);
      });
      AciklamaController.clear();
      KGController.clear();
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: 'Ekstra Hareket Eklendi',
        ),
      );
    }
  }

  Widget EkstraPopUp(ChildMalzemeler malzeme) {
    bool eksiStok = true;
    String odeme_s = "EKSİLİŞ";
    return StatefulBuilder(builder: (cntxt, setSB) {
      return Container(
        margin: const EdgeInsets.all(8),
        child: SizedBox(
          height: 278,
          width: double.infinity,
          child: Column(
            children: [
              TextField(
                inputFormatters: [ThousandsFormatter(allowFraction: true)],
                keyboardType: TextInputType.number,
                maxLength: 12,
                maxLines: 1,
                decoration: const InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  labelText: "Hareket KG",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black45,
                    ),
                  ),
                ),
                controller: KGController,
              ),
              Divider(
                height: 5,
                color: Colors.white,
              ),
              TextField(
                keyboardType: TextInputType.text,
                maxLines: 1,
                maxLength: 15,
                decoration: const InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  labelText: "Hareket Açıklaması",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black45,
                    ),
                  ),
                ),
                controller: AciklamaController,
              ),
              Divider(
                height: 10,
                color: Colors.black,
              ),
              Column(
                children: [
                  Switch(
                      activeColor: Colors.red,
                      inactiveTrackColor: Colors.greenAccent,
                      value: eksiStok,
                      onChanged: (newval) {
                        setSB(() {
                          eksiStok = newval;
                          odeme_s = eksiStok ? "ÇIKIŞ" : "GİRİŞ";
                        });
                      }),
                  Text(
                    odeme_s,
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              Divider(
                height: 10,
                color: Colors.black,
              ),
              OutlinedButton(
                child: Text("EKLE"),
                onPressed: () {
                  EkstraEkleFunc(eksiStok, malzeme);
                },
              )
            ],
          ),
        ),
      );
    });
  }

  var KGController = TextEditingController();
  var AciklamaController = TextEditingController();
  void EkstraEkleDialog(ChildMalzemeler malzeme) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: EkstraPopUp(malzeme),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        });
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
          height: MediaQuery.of(context).size.height * 0.55,
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
                  EkstraEkleDialog(ChildMalzemeList[i]);
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
                    "${add_comma_to_double(ChildMalzemeList[i].stokKG).replaceAll(regex, '')}KG",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.pink,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HarekerRaporPage(child: ChildMalzemeList[i])),
                    );
                  },
                ),
              );
            },
          ),
        ),
        Text("ALT MALZEMELER"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BackButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
              );
            },
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IslemAyarlar()),
                );
              },
              child: Text("MALZEME AYARLARI"))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: BackgroundWaveClipper(),
              child: Container(
                child: Image.asset(
                  "images/depot.png",
                  scale: 3,
                ),
                padding: EdgeInsets.all(50),
                width: MediaQuery.of(context).size.width,
                height: 280,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Color(0xFFFACCCC), Color(0xFFF6EFE9)],
                )),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnaMalzemelerWidget(),
                ChildMalzemelerWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
