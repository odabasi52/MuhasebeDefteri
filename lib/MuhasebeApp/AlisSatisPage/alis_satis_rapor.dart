import 'package:flutter/material.dart';

/*My Libs*/
import 'package:muhasebe/MuhasebeApp/CariPage/islemler/islemler_sayfasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CariPage/Cari/user.dart';
import '../CariPage/Faturalar/faturalar.dart';
import '../CommonUsed/CurvedAppBar.dart';
import '../CommonUsed/Functions.dart';

/*Others*/
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class RaporPage extends StatefulWidget {
  RaporPage({super.key, required this.satis});
  bool satis;

  @override
  State<RaporPage> createState() => _RaporPageState();
}

class _RaporPageState extends State<RaporPage> {
  List<Faturalar> faturalar = [];
  List<Faturalar> filteredFaturalar = [];

  List<User> musteriList = [];

  void LoadList() async {
    dropdownValueZaman = "TÜMÜ";
    kisiFaturaString = "";
    final prefs = await SharedPreferences.getInstance();
    String? musteriString = prefs.getString("musteriler");
    List<Faturalar> geciciFaturalar = [];
    faturalar = [];
    filteredFaturalar = [];
    setState(() {
      if (musteriString == " " || musteriString == null) {
        musteriList = [];
      } else {
        musteriList = User.decode(musteriString.toString());
      }

      for (int i = 0; i < musteriList.length; i++) {
        geciciFaturalar = [];
        if(musteriList[i].faturaString == "" || musteriList[i].faturaString == " "){}else{
          geciciFaturalar = Faturalar.decode(musteriList[i].faturaString);
        }
        for (int a = 0; a < geciciFaturalar.length; a++) {
          geciciFaturalar[a].kisi = musteriList[i];
          if (widget.satis && geciciFaturalar[a].gelir) {
            faturalar.add(geciciFaturalar[a]);
          } else if (!widget.satis && !geciciFaturalar[a].gelir) {
            faturalar.add(geciciFaturalar[a]);
          }
        }
      }
      faturalar.sort(
        (a, b) => DateTime.parse(a.fatura_tarihi)
            .compareTo(DateTime.parse(b.fatura_tarihi)),
      );

      faturalar = faturalar.reversed.toList();
      filteredFaturalar = faturalar;
    });
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

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  String ToplamPara(List<Faturalar> suggestion) {
    double d_toplampara = 0;
    for (int i = 0; i < suggestion.length; i++) {
      d_toplampara += double.parse(suggestion[i].toplamBorc);
    }

    return "Toplam : ${d_toplampara}TL".replaceAllMapped(reg, mathFunc);
  }

  //Takvim açmak için filtreleme
  DateTime date_start = DateTime(2022);
  DateTime date_end = DateTime(2022);
  void OpenTakvim() async {
    DateTimeRange? dates = await showDateRangePicker(
        context: context, firstDate: DateTime(2022), lastDate: DateTime(2050));
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

  //Listeyi Filtrele
  void filterList() {
    List<Faturalar> suggestion0 = faturalar;

    if (kisiFaturaString == "" || kisiFaturaString == " ") {
    } else {
      User musteri = User("", "", "", "", "", "", 0, "");
      for (User m in musteriList) {
        if (m.faturaString == kisiFaturaString) {
          musteri = m;
        }
      }
      suggestion0 = [];
      List<Faturalar> geciciFaturalar = Faturalar.decode(musteri.faturaString);
      for (Faturalar fatura in geciciFaturalar) {
        fatura.kisi = musteri;
      }

      for (int i = 0; i < geciciFaturalar.length; i++) {
        if (widget.satis && geciciFaturalar[i].gelir) {
          suggestion0.add(geciciFaturalar[i]);
        } else if (!widget.satis && !geciciFaturalar[i].gelir) {
          suggestion0.add(geciciFaturalar[i]);
        }
      }
    }

    var suggestion = suggestion0.where(
      (element) {
        if (dropdownValueZaman == "TAKVİM") {
          DateTime date = DateTime.parse(element.fatura_tarihi);
          int days_fatura_tarihi = daysBetween(DateTime(2022), date);
          int days_start = daysBetween(DateTime(2022), date_start);
          int days_end = daysBetween(DateTime(2022), date_end);
          if (days_fatura_tarihi <= days_end &&
              days_fatura_tarihi >= days_start) {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      },
    ).toList();
    filteredFaturalar = suggestion;
  }

  Widget fatura_tarihi(Faturalar fatura) {
    DateTime tarih = DateTime.parse(fatura.fatura_tarihi);
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
  void initState() {
    // TODO: implement initState
    super.initState();
    LoadList();
  }

  void KisiSecDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, SetSB) {
            return AlertDialog(
              content: KisiSecPopUp(SetSB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );
          });
        });
  }
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String Function(Match) mathFunc = (Match match) => '${match[1]},';
  
  List<User> filteredMusteriList = [];
  String kisiFaturaString = "";
  var KisiController = TextEditingController();
  int x = 0;
  Widget KisiSecPopUp(SetSB) {
    if (x == 0) {
      x++;
      SetSB(() {
        filteredMusteriList = musteriList;
      });
    }
    return RefreshIndicator(
      onRefresh: () async {
        SetSB(() {
          filteredMusteriList = musteriList;
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
                  final suggestion = musteriList.where((musteri) {
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
            height: 200,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: filteredMusteriList.length,
              itemBuilder: (_, i) {
                return ListTile(
                  leading: IconButton(
                    icon:
                        Icon(Icons.person_outline_rounded, color: Colors.pink),
                    onPressed: () => setState(() {
                      kisiFaturaString = filteredMusteriList[i].faturaString;
                      filterList();
                      Navigator.pop(context);
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.info(
                          message:(kisiFaturaString==""||kisiFaturaString==" ")?"${filteredMusteriList[i].username} Kişisine Ait\nBorç Bulunmamaktadır.":"${filteredMusteriList[i].username} Kişisine Ait Borçlar",
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
                    "Borç: " +
                        filteredMusteriList[i].kisi_borcu.toString().replaceAllMapped(reg, mathFunc).replaceAll(regex, '') +
                        "TL",
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String PersonInfos(User? musteri) {
    if (musteri == null) {
      return "";
    } else {
      return "${musteri.username}\nTC: ${musteri.id}\nTEL: ${musteri.telefon}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BackButton(),
          Text(
            ToplamPara(filteredFaturalar).replaceAll(regex, ''),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          dropDownZaman(),
          ElevatedButton(
            onPressed: KisiSecDialog,
            child: Text("KİŞİ SEÇ"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: BackgroundWaveClipper(),
              child: Container(
                child: Text(
                  widget.satis ? "SATIŞ RAPORU" : "ALIŞ RAPORU",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      fontStyle: FontStyle.italic),
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
            Container(
                height: 440,
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      LoadList();
                    });
                  },
                  child: ListView.builder(
                    itemBuilder: (context, i) {
                      return Card(
                        margin: const EdgeInsets.all(4),
                        elevation: 8,
                        child: ListTile(
                          onLongPress: () => setState(() {
                            User musteri = User("", "", "", "", "", "", 0, "");
                            for (int a = 0; a < musteriList.length; a++) {
                              if (musteriList[a].faturaString ==
                                  Faturalar.encode(faturalar)) {
                                musteri = musteriList[a];
                              }
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => IslemlerSayfasi(
                                        fatura: filteredFaturalar[i],
                                        faturaList: faturalar,
                                        musteri: musteri,
                                        musteriler: musteriList,
                                      )),
                            );
                          }),
                          title: Text("${filteredFaturalar[i].toplamBorc.replaceAllMapped(reg, mathFunc).replaceAll(regex, '')}TL"),
                          subtitle: fatura_tarihi(filteredFaturalar[i]),
                          trailing:
                              Text(PersonInfos(filteredFaturalar[i].kisi)),
                        ),
                      );
                    },
                    itemCount: filteredFaturalar.length,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
