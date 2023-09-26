import 'package:flutter/material.dart';

/*My Libs*/
import "malzemeler.dart";
import '../CommonUsed/Functions.dart';

/*Others*/
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

class MalzemelerPage extends StatefulWidget {
  const MalzemelerPage({super.key});

  @override
  State<MalzemelerPage> createState() => _MalzemelerPageState();
}

class _MalzemelerPageState extends State<MalzemelerPage> {
  List<AnaMalzemeler> AnaMalzemeList = [];
  List<ChildMalzemeler> ChildMalzemeList = [];
  var AnaMalzemeIsmi = TextEditingController();
  var ChildMalzemeIsmi = TextEditingController();

  Future<void> SaveAnaMalzemeList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = AnaMalzemeler.encode(AnaMalzemeList);
    await prefs.setString("AnaMalzemeler", encodedData);
  }

  void LoadAnaMalzemeList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final malzemeStr = prefs.getString("AnaMalzemeler") ?? " ";
    setState(() {
      if (malzemeStr == " ") {
        AnaMalzemeList = [];
      } else {
        AnaMalzemeList = AnaMalzemeler.decode(malzemeStr);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    LoadAnaMalzemeList();
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
              return Dismissible(
                background: Container(
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.red),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                  ),
                ),
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                onDismissed: (dir) {
                  DialogShower(MalzemeSilPopUp(i, true));
                },
                child: ListTile(
                  onLongPress: () {
                    ChildMalzemeShow(AnaMalzemeList[i]);
                  },
                  trailing: IconButton(
                      onPressed: () {
                        DialogShower(ChildEklePopUp(AnaMalzemeList[i]));
                      },
                      icon: Icon(
                        Icons.playlist_add,
                        color: Colors.pink,
                      )),
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
                      "${AnaMalzemeList[i].stokKG}KG",
                      style: const TextStyle(fontSize: 13),
                    ),
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
              return Dismissible(
                background: Container(
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.red),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                  ),
                ),
                key: UniqueKey(),
                direction: DismissDirection.startToEnd,
                onDismissed: (dir) {
                  DialogShower(MalzemeSilPopUp(i, false));
                },
                child: ListTile(
                  onLongPress: () {
                    DialogShower(ChildGuncellePopUp(ChildMalzemeList[i]));
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
                      "ALIŞ: ${ChildMalzemeList[i].alis_fiyat}TL\nSATIŞ: ${ChildMalzemeList[i].satis_fiyat}TL\nSTOK: ${ChildMalzemeList[i].stokKG}KG",
                      style: const TextStyle(fontSize: 12),
                    ),
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

  void AnaMalzemeEkle() {
    final ana_malzeme_ismi =
        replacedString(AnaMalzemeIsmi.text.toUpperCase().trim());

    if (ana_malzeme_ismi == "")
      return ;

    bool malzeme_var = false;
    for (AnaMalzemeler malzeme in AnaMalzemeList) {
      if (malzeme.malzemeIsim == ana_malzeme_ismi) {
        malzeme_var = true;
      }
    }

    if (malzeme_var) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Aynı Malzemeden Birden Fazla Ekleyemezsiniz.',
        ),
      );
    } else {
      AnaMalzemeIsmi.clear();
      AnaMalzemeList.add(AnaMalzemeler(ana_malzeme_ismi, 0, ""));
      SaveAnaMalzemeList();
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: 'Malzeme Ana Malzemelere Eklendi',
        ),
      );
    }
  }

  void MalzemeSilFunc(index, bool ana_malzeme) {
    if (ana_malzeme) {
      AnaMalzemeList.removeAt(index);
      ChildMalzemeList = [];
    } else {
      final MalzemeIsmi = ChildMalzemeList[index].anaMalzeme;
      final stok_eksilme_kg = ChildMalzemeList[index].stokKG;
      ChildMalzemeList.removeAt(index);

      for (AnaMalzemeler mal in AnaMalzemeList) {
        if (mal.malzemeIsim == MalzemeIsmi) {
          mal.ChildMalzemeListString = ChildMalzemeler.encode(ChildMalzemeList);
          mal.stokKG -= stok_eksilme_kg;
        }
      }
    }
    SaveAnaMalzemeList();
    LoadAnaMalzemeList();
  }

  void ChildEkleFunc(AnaMalzemeler mal) {
    final AlisText = AlisParaController.text.replaceAll(",", "").trim();
    final SatisText = SatisParaController.text.replaceAll(",", "").trim();
    final StokKGText = StokKGController.text.replaceAll(",", "").trim();
    final MalzemeIsmiText = replacedString(MalzemeIsmiController.text.trim().toUpperCase());

    if (double.tryParse(AlisText) == null ||
        double.tryParse(SatisText) == null ||
        double.tryParse(StokKGText) == null) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'SAYI DEĞERLERİ HATALI',
        ),
      );
    } else if (double.parse(AlisText) < 0 ||
        double.parse(SatisText) < 0 ||
        double.parse(StokKGText) < 0) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'SAYI DEĞERLERİ NEGATİF OLAMAZ',
        ),
      );
    } else if (MalzemeIsmiText.replaceAll(" ", "") == "") {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'Malzeme İsmi Giriniz',
        ),
      );
    } else {
      setState(() {
        var childMalzeme = ChildMalzemeler(
            MalzemeIsmiText,
            double.parse(StokKGText),
            double.parse(AlisText),
            double.parse(SatisText),
            mal.malzemeIsim,
            HareketRaporu.encode([HareketRaporu("OLUSTURULDU", DateTime.now().toString(), double.parse(StokKGText))]));

        List<ChildMalzemeler> ChildList = [];
        if (mal.ChildMalzemeListString != "") {
          ChildList = ChildMalzemeler.decode(mal.ChildMalzemeListString);
        }

        for (ChildMalzemeler child in ChildList) {
          if (MalzemeIsmiText == child.childIsim) {
            showTopSnackBar(
              Overlay.of(context),
              CustomSnackBar.error(
                message: 'Aynı Malzemeden Birden Fazla Ekleyemezsiniz.',
              ),
            );
            return;
          }
        }

        ChildList.add(childMalzeme);
        mal.ChildMalzemeListString = ChildMalzemeler.encode(ChildList);
        mal.stokKG += double.parse(StokKGText);
        ChildMalzemeList = ChildList;
        SaveAnaMalzemeList();
        LoadAnaMalzemeList();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.info(
            message: 'ALT MALZEME EKLEME BAŞARILI',
          ),
        );
        Navigator.pop(context);
        AlisParaController.clear();
        SatisParaController.clear();
        StokKGController.clear();
        MalzemeIsmiController.clear();
      });
    }
  }

  void ChildGuncelleFunc(ChildMalzemeler child) {
    final AlisText = AlisParaController.text.replaceAll(",", "").trim();
    final SatisText = SatisParaController.text.replaceAll(",", "").trim();
    final StokText = StokKGController.text.replaceAll(",", "").trim();

    double alis = child.alis_fiyat;
    double satis = child.satis_fiyat;
    double stokKG = child.stokKG;

    if (AlisText.replaceAll(" ", "") != "") {
      if (double.tryParse(AlisText) == null) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'ALIŞ FİYATI HATALI',
          ),
        );
      } else if (double.parse(AlisText) < 0) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'ALIŞ FİYATI NEGATİF OLAMAZ',
          ),
        );
      } else {
        alis = double.parse(AlisText);
      }
    }

    if (SatisText.replaceAll(" ", "") != "") {
      if (double.tryParse(SatisText) == null) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'SATIŞ FİYATI HATALI',
          ),
        );
      } else if (double.parse(SatisText) < 0) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'SATIŞ FİYATI NEGATİF OLAMAZ',
          ),
        );
      } else {
        satis = double.parse(SatisText);
      }
    }

    if (StokText.replaceAll(" ", "") != "") {
      if (double.tryParse(StokText) == null) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'SATIŞ FİYATI HATALI',
          ),
        );
      } else if (double.parse(StokText) < 0) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'SATIŞ FİYATI NEGATİF OLAMAZ',
          ),
        );
      } else {
        stokKG = double.parse(StokText);
      }
    }

    child.alis_fiyat = alis;
    child.satis_fiyat = satis;

    for (AnaMalzemeler mal in AnaMalzemeList) {
      if (mal.malzemeIsim == child.anaMalzeme) {
        mal.stokKG += (stokKG - child.stokKG);
        child.stokKG = stokKG;
        mal.ChildMalzemeListString = ChildMalzemeler.encode(ChildMalzemeList);
      }
    }
    SaveAnaMalzemeList();
    LoadAnaMalzemeList();
    AlisParaController.clear();
    SatisParaController.clear();
    StokKGController.clear();
    Navigator.pop(context);
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

  Widget MalzemeSilPopUp(i, bool ana_malzeme) {
    return StatefulBuilder(builder: (context, setStateSB) {
      return Container(
        padding: const EdgeInsets.all(8),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () => setStateSB(() {
                      MalzemeSilFunc(i, ana_malzeme);
                      Navigator.of(context).pop();
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.info(
                          message: 'MALZEME KALICI OLARAK SİLİNDİ',
                        ),
                      );
                    }),
                child: Text("SİL")),
            ElevatedButton(
                onPressed: () => setStateSB(() {
                      Navigator.of(context).pop();
                      LoadAnaMalzemeList();
                    }),
                child: Text("İPTAL")),
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

  var StokKGController = TextEditingController();
  var AlisParaController = TextEditingController();
  var SatisParaController = TextEditingController();
  var MalzemeIsmiController = TextEditingController();
  Widget ChildEklePopUp(AnaMalzemeler mal) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: SizedBox(
        height: 278,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              maxLength: 15,
              controller: MalzemeIsmiController,
              maxLines: 1,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8),
                isDense: true,
                labelText: "Malzeme İsmi",
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black45,
                  ),
                ),
              ),
            ),
            TextFieldForNumbers(AlisParaController, "Alış Fiyatı"),
            TextFieldForNumbers(SatisParaController, "Satış Fiyatı"),
            TextFieldForNumbers(StokKGController, "Stok KG"),
            ElevatedButton(
                onPressed: () {
                  ChildEkleFunc(mal);
                },
                child: Text("EKLE"))
          ],
        ),
      ),
    );
  }

  Widget ChildGuncellePopUp(child) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFieldForNumbers(AlisParaController, "Alış Fiyatı"),
            TextFieldForNumbers(SatisParaController, "Satış Fiyatı"),
            TextFieldForNumbers(StokKGController, "Stok KG"),
            ElevatedButton(
                onPressed: () {
                  ChildGuncelleFunc(child);
                },
                child: Text("GÜNCELLE"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.88,
                child: TextField(
                  decoration: InputDecoration(
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          AnaMalzemeEkle();
                        });
                      },
                      child: Icon(
                        Icons.add_business_outlined,
                        color: Colors.pink,
                      ),
                    ),
                    labelText: "Ana Malzeme İsmi",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  controller: AnaMalzemeIsmi,
                  maxLength: 15,
                ),
              ),
              Divider(
                height: 10,
                color: Colors.white,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnaMalzemelerWidget(),
                  ChildMalzemelerWidget(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
