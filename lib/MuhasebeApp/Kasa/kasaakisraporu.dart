import 'package:flutter/material.dart';

//My Libs
import '../CariPage/Cari/hesapcuzdan.dart';
import '../CariPage/Cari/user.dart';
import '../CommonUsed/CurvedAppBar.dart';
import '../CommonUsed/Functions.dart';

//Others
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:pattern_formatter/pattern_formatter.dart';


class KasaPage extends StatefulWidget {
  const KasaPage({super.key});

  @override
  State<KasaPage> createState() => _KasaPageState();
}

class _KasaPageState extends State<KasaPage> {
  List<User> kisiler = [];
  List<Cuzdan> filteredOdemeler = [];
  List<Cuzdan> odemeler = [];
  List<Cuzdan> ekstralar = [];

  void LoadList() async {
    final prefs = await SharedPreferences.getInstance();
    String musteriString = prefs.getString("musteriler") ?? "";
    String ekstraString = prefs.getString("ekstra_ödemeler") ?? "";

    if (musteriString == "") {
      kisiler = [];
    } else {
      kisiler = User.decode(musteriString.toString());
    }

    odemeler = [];
    ekstralar = [];
    if (ekstraString != "") {
      ekstralar = Cuzdan.decode(ekstraString);
      ekstralar.forEach((element) {
        odemeler.add(element);
      });
    }
    for (int i = 0; i < kisiler.length; i++) {
      if (kisiler[i].cuzdanString != " ") {
        List<Cuzdan> cuzdan = Cuzdan.decode(kisiler[i].cuzdanString);
        for (int i = 0; i < cuzdan.length; i++) {
          odemeler.add(cuzdan[i]);
        }
      }
    }

    setState(() {
      odemeler.sort(
        (a, b) => DateTime.parse(a.tarih).compareTo(DateTime.parse(b.tarih)),
      );
      filteredOdemeler = odemeler.reversed.toList();
    });
    saveKasaOdeme();
  }

  void saveKasaOdeme() async {
    final prefs = await SharedPreferences.getInstance();
    final odemeString = Cuzdan.encode(odemeler);
    prefs.setString("kasa_ödemeler", odemeString);
  }

  void saveEkstraOdemeler() async {
    final prefs = await SharedPreferences.getInstance();
    final ekString = Cuzdan.encode(ekstralar);
    prefs.setString("ekstra_ödemeler", ekString);
  }

  Widget tarih(i) {
    DateTime tarih = DateTime.parse(filteredOdemeler[i].tarih);
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

  String dropdownValueZaman = "TÜMÜ";
  Widget dropDownZaman() {
    return DropdownButton<String>(
      value: dropdownValueZaman,
      icon: const Icon(
        Icons.arrow_drop_down_circle_outlined,
        color: Colors.pinkAccent,
      ),
      elevation: 10,
      style: const TextStyle(color: Colors.black87),
      onChanged: (value) {
        setState(() {
          dropdownValueZaman = value!;
          if (dropdownValueZaman == "TAKVİM") {
            OpenTakvim();
          } else {
            filterList();
          }
        });
      },
      items: ["TÜMÜ", "TAKVİM"].map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  String dropdownValueLeading = "TÜMÜ";
  Widget dropDown() {
    return DropdownButton<String>(
      value: dropdownValueLeading,
      icon: const Icon(
        Icons.arrow_drop_down_circle_outlined,
        color: Colors.pinkAccent,
      ),
      elevation: 10,
      style: const TextStyle(color: Colors.black87),
      onChanged: (value) {
        setState(() {
          dropdownValueLeading = value!;
          filterList();
        });
      },
      items: ["TÜMÜ", "NAKİT", "KART"]
          .map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  //Takvim açmak için filtreleme
  DateTime date_start = DateTime(2022);
  DateTime date_end = DateTime(2022);
  void OpenTakvim() async {
    DateTimeRange? dates = await showDateRangePicker(
        context: context, firstDate: DateTime(2022), lastDate: DateTime(2040));
    if (dates != null) {
      date_start = dates.start;
      date_end = dates.end;
    } else {
      dropdownValueZaman = "TÜMÜ";
    }
    setState(() {
      filterList();
    });
  }

  void filterList() {
    List<Cuzdan> suggestion0 = [];
    if (odeme_disi_islemler) {
      odeme_disi_islemler = false;
      for (Cuzdan cuzdan in odemeler) {
        if (cuzdan.odeme_disi != null) {
          suggestion0.add(cuzdan);
        }
      }
    } else {
      suggestion0 = odemeler;
      if (kisiCuzdanString == "" || kisiCuzdanString == " ") {
      } else {
        suggestion0 = Cuzdan.decode(kisiCuzdanString);
      }
    }

    var suggestion = suggestion0.where(
      (element) {
        if (dropdownValueZaman == "TAKVİM") {
          final date = DateTime.parse(element.tarih);
          int days_hesap_tarihi = daysBetween(DateTime(2022), date);
          int days_start = daysBetween(DateTime(2022), date_start);
          int days_end = daysBetween(DateTime(2022), date_end);
          if (days_hesap_tarihi <= days_end &&
              days_hesap_tarihi >= days_start) {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      },
    ).toList();

    var suggestion2 = suggestion.where(
      (element) {
        if (dropdownValueLeading == "TÜMÜ") {
          return true;
        }

        bool eleman = false;
        if (element.kart && dropdownValueLeading == "KART") {
          eleman = true;
        } else if (!element.kart && dropdownValueLeading == "NAKİT") {
          eleman = true;
        }
        return eleman;
      },
    ).toList();

    suggestion2.sort(
      (a, b) => DateTime.parse(a.tarih).compareTo(DateTime.parse(b.tarih)),
    );

    filteredOdemeler = suggestion2.reversed.toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LoadList();
  }

  void KisiSecDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: StatefulBuilder(builder: (context, setSB) {
              return KisiSecPopUp(setSB);
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        });
  }

  var ParaController = TextEditingController();
  var AciklamaController = TextEditingController();
  void EkstraEkleDialog() {
    bool nakit = true;
    String nakit_s = "NAKİT";

    bool odeme_borc = true;
    String odeme_s = "TEDİYE";
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: StatefulBuilder(builder: (context, setSB) {
              return Container(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 278,
                  width: double.infinity,
                  child: Column(
                    children: [
                      TextField(
                        inputFormatters: [
                          ThousandsFormatter(allowFraction: true)
                        ],
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          contentPadding: const EdgeInsets.all(8),
                          labelText: "Ekstra Ödeme (TL)",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black45,
                            ),
                          ),
                        ),
                        controller: ParaController,
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
                          labelText: "Ödeme Açıklaması",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Switch(
                                  activeColor: Colors.green,
                                  inactiveTrackColor: Colors.blue,
                                  value: nakit,
                                  onChanged: (newval) {
                                    setSB(() {
                                      nakit = newval;
                                      nakit_s = nakit ? "NAKİT" : "KART";
                                    });
                                  }),
                              Text(
                                nakit_s,
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Switch(
                                  activeColor: Colors.red,
                                  inactiveTrackColor: Colors.greenAccent,
                                  value: odeme_borc,
                                  onChanged: (newval) {
                                    setSB(() {
                                      odeme_borc = newval;
                                      odeme_s = odeme_borc ? "TEDİYE" : "TAHSİLAT";
                                    });
                                  }),
                              Text(
                                odeme_s,
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                        ],
                      ),
                      Divider(
                        height: 10,
                        color: Colors.black,
                      ),
                      OutlinedButton(
                        child: Text("EKLE"),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                            ekstraOdemeEkle(odeme_borc, nakit);
                          });
                        },
                      )
                    ],
                  ),
                ),
              );
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        });
  }

  void ekstraOdemeEkle(bool borc, bool nakit) {
    if (double.tryParse(ParaController.text.replaceAll(',', "")) == null) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Geçerli sayı değeri giriniz',
        ),
      );
    } else if (double.parse(ParaController.text.replaceAll(',', "")) <= 0) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Pozitif (+) sayı değeri giriniz',
        ),
      );
    } else if (AciklamaController.text.replaceAll(" ", "") == "") {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Açıklama giriniz',
        ),
      );
    } else {
      setState(() {
        ekstralar.add(Cuzdan(
            double.parse(ParaController.text.replaceAll(',', "")),
            DateTime.now().toString(),
            !borc,
            !nakit,
            replacedString(AciklamaController.text.toUpperCase())));
      });
      saveEkstraOdemeler();
      LoadList();
    }
    ParaController.clear();
    AciklamaController.clear();
  }

  List<User> filteredMusteriList = [];
  String kisiCuzdanString = "";
  var KisiController = TextEditingController();
  int x = 0;
  bool odeme_disi_islemler = false;
  Widget KisiSecPopUp(SetSB) {
    if (x == 0) {
      x++;
      SetSB(() {
        filteredMusteriList = kisiler;
      });
    }
    return RefreshIndicator(
      onRefresh: () async {
        SetSB(() {
          filteredMusteriList = kisiler;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            child: SizedBox(
              height: 45,
              width: double.infinity,
              child: TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_search_rounded),
                  labelText: "İsim - TC - Tel",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black45,
                    ),
                  ),
                ),
                controller: KisiController,
                onSubmitted: (query) {
                  final suggestion = kisiler.where((musteri) {
                    final isim = musteri.username.toUpperCase();
                    final tc_kimlik = musteri.id;
                    final arama = query.toUpperCase();
                    if (int.tryParse(query) == null) {
                      return isim.contains(arama);
                    } else if (query == tc_kimlik) {
                      return tc_kimlik == arama;
                    } else {
                      return musteri.telefon == arama;
                    }
                  }).toList();
                  SetSB(() {
                    filteredMusteriList = suggestion;
                    KisiController.clear();
                  });
                },
              ),
            ),
          ),
          SizedBox(
            height: 150,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: filteredMusteriList.length,
              itemBuilder: (_, i) {
                return ListTile(
                  leading: IconButton(
                    icon:
                        Icon(Icons.person_outline_rounded, color: Colors.pink),
                    onPressed: () => setState(() {
                      kisiCuzdanString = filteredMusteriList[i].cuzdanString;
                      filterList();
                      Navigator.pop(context);
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.info(
                          message: (kisiCuzdanString == "" ||
                                  kisiCuzdanString == " ")
                              ? "${filteredMusteriList[i].username} Kişisine Ait\nÖdeme Bulunmamaktadır."
                              : "${filteredMusteriList[i].username} Kişisine Ait Ödemeler",
                        ),
                      );
                    }),
                  ),
                  title: Text(
                    filteredMusteriList[i].username,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Borç: ${add_comma_to_double(filteredMusteriList[i].kisi_borcu.toString().replaceAll(regex, ''))} TL" ,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),
          Divider(
            color: Colors.black,
            height: 10,
          ),
          OutlinedButton(
              onPressed: () => setState(() {
                    odeme_disi_islemler = true;
                    filterList();
                    Navigator.pop(context);
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.info(message: "ÖDEME DIŞI İŞLEMLER"),
                    );
                  }),
              child: Text("ÖDEME DIŞI İŞLEMLER"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          dropDownZaman(),
          dropDown(),
          ElevatedButton(
            onPressed: KisiSecDialog,
            child: Text("KİŞİ SEÇ"),
          ),
          ElevatedButton(
            onPressed: EkstraEkleDialog,
            child: Text("EKSTRA"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: BackgroundWaveClipper(),
              child: Container(
                child: Image.asset("images/bank.png", scale: 5),
                padding: EdgeInsets.all(50),
                width: MediaQuery.of(context).size.width,
                height: 280,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Color(0xFFFACCCC), Color(0xFFF6EFE9)],
                )),
              ),
            ),
            Container(
              height: 240,
              child: RefreshIndicator(
                onRefresh: () async {
                  kisiCuzdanString = "";
                  dropdownValueLeading = "TÜMÜ";
                  dropdownValueZaman = "TÜMÜ";
                  setState(() => filterList());
                },
                child: ListView.builder(
                  itemBuilder: (context, i) {
                    return Card(
                      margin: const EdgeInsets.all(4),
                      elevation: 8,
                      child: ListTile(
                        leading: Text(
                          (filteredOdemeler[i].kart ? "KART" : "NAKİT"),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: !filteredOdemeler[i].eksildi
                                  ? Colors.red
                                  : Colors.green),
                        ),
                        title: Text(
                          filteredOdemeler[i].odeme_disi == null
                              ? (!filteredOdemeler[i].eksildi
                                  ? "${add_comma_to_double(filteredOdemeler[i].odenen).replaceAll(regex, '')}TL Ödeme Yapıldı "
                                  : "${add_comma_to_double(filteredOdemeler[i].odenen).replaceAll(regex, '')}TL Ödeme Alındı ")
                              : "${add_comma_to_double(filteredOdemeler[i].odenen).replaceAll(regex, '')}TL ${filteredOdemeler[i].odeme_disi} ",
                          style: TextStyle(fontSize: 15),
                        ),
                        subtitle: tarih(i),
                        trailing: filteredOdemeler[i].odeme_disi == null
                            ? Text("")
                            : IconButton(
                                onPressed: () {
                                  var odeme_ = null;
                                  for (var odeme in odemeler) {
                                    if (odeme == filteredOdemeler[i]) {
                                      odeme_ = odeme;
                                    }
                                  }
                                  setState(() {
                                    ekstralar.remove(odeme_);
                                    saveEkstraOdemeler();
                                    odemeler.remove(odeme_);
                                    filteredOdemeler.removeAt(i);
                                    saveKasaOdeme();
                                  });
                                },
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.pink,
                                )),
                      ),
                    );
                  },
                  itemCount: filteredOdemeler.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
