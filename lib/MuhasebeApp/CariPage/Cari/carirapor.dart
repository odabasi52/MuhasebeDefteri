import 'package:flutter/material.dart';

/*My Libs*/
import 'package:muhasebe/MuhasebeApp/CariPage/Cari/user.dart';
import 'package:muhasebe/MuhasebeApp/CariPage/Faturalar/faturalar.dart';
import 'package:muhasebe/MuhasebeApp/CariPage/Cari/hesapcuzdan.dart';
import '../../CommonUsed/CurvedAppBar.dart';
import '../../CommonUsed/Functions.dart';

class CariRapor extends StatefulWidget {
  CariRapor({super.key, required this.musteri});
  User musteri;

  @override
  State<CariRapor> createState() => _CariRaporState();
}

class _CariRaporState extends State<CariRapor> {
  List<List<String>> filteredList = [];
  List<List<String>> raporListesi() {
    List<List<String>> raporList = [];
    List<Cuzdan> kisi_cuzdan = [];
    if (widget.musteri.cuzdanString != " ") {
      kisi_cuzdan = Cuzdan.decode(widget.musteri.cuzdanString);
      ;
    }
    List<Faturalar> kisi_fatura = [];
    if (widget.musteri.faturaString != " ") {
      kisi_fatura = Faturalar.decode(widget.musteri.faturaString);
    }

    for (int i = 0; i < kisi_cuzdan.length; i++) {
      String cuzdan = "";
      DateTime tarih = DateTime.parse(kisi_cuzdan[i].tarih);
      String odeme_tarihi = tarih.day.toString().padLeft(2, "0") +
          "/" +
          tarih.month.toString().padLeft(2, "0") +
          "/" +
          tarih.year.toString() +
          " - " +
          tarih.hour.toString().padLeft(2, "0") +
          ":" +
          tarih.minute.toString().padLeft(2, "0");
      if (!kisi_cuzdan[i].eksildi) {
        cuzdan = "${kisi_cuzdan[i].odenen.toString().replaceAll(regex, '')}TL Ödeme Yapıldı\n${odeme_tarihi}";
        raporList.add([cuzdan, kisi_cuzdan[i].tarih.toString(), "BORÇ"]);
      } else {
        cuzdan = "${kisi_cuzdan[i].odenen.toString().replaceAll(regex, '')}TL Ödeme Alındı\n${odeme_tarihi}";
        raporList.add([cuzdan, kisi_cuzdan[i].tarih.toString(), "ALACAK"]);
      }
    }
    for (int i = 0; i < kisi_fatura.length; i++) {
      String cuzdan = "";
      DateTime tarih = DateTime.parse(kisi_fatura[i].fatura_tarihi);
      String fatura_tarihi = tarih.day.toString().padLeft(2, "0") +
          "/" +
          tarih.month.toString().padLeft(2, "0") +
          "/" +
          tarih.year.toString() +
          " - " +
          tarih.hour.toString().padLeft(2, "0") +
          ":" +
          tarih.minute.toString().padLeft(2, "0");
      if (kisi_fatura[i].gelir) {
        cuzdan =
            "${kisi_fatura[i].toplamBorc.replaceAll(regex, '')}TL Fatura (Satış)\n${fatura_tarihi}";
        raporList
            .add([cuzdan, kisi_fatura[i].fatura_tarihi.toString(), "BORÇ"]);
      } else {
        cuzdan =
            "${kisi_fatura[i].toplamBorc.replaceAll(regex, '')}TL Fatura (Alış)\n${fatura_tarihi}";
        raporList
            .add([cuzdan, kisi_fatura[i].fatura_tarihi.toString(), "ALACAK"]);
      }
    }

    raporList.sort(
      (a, b) => DateTime.parse(a[1]).compareTo(DateTime.parse(b[1])),
    );

    return raporList.reversed.toList();
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  void filterList() {
    var suggestion = raporListesi().where(
      (element) {
        if (dropdownValueZaman == "TAKVİM") {
          final date = DateTime.parse(element[1]);
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
        if (element[2] == dropdownValueLeading) {
          eleman = true;
        }
        return eleman;
      },
    ).toList();

    suggestion2.sort(
      (a, b) => DateTime.parse(a[1]).compareTo(DateTime.parse(b[1])),
    );

    filteredList = suggestion2.reversed.toList();
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
      items: ["TÜMÜ", "BORÇ", "ALACAK"]
          .map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
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

  String bakiye() {
    String bakiyev = widget.musteri.kisi_borcu >= 0
        ? widget.musteri.kisi_borcu.toString() + "TL \tBORÇ"
        : widget.musteri.kisi_borcu.toString() + "TL \tALACAK";
    return bakiyev;
  }

  Widget PersonCard() {
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text('Müşteri adı:  ${widget.musteri.username}'),
      subtitle: Text(
        'TC No:  ${widget.musteri.id}\nTelefon:  ${widget.musteri.telefon}\nKişi Bakiyesi:  ${bakiye().replaceAll("-", "").replaceAll(regex, '')}',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    filteredList = raporListesi();
    filterList();
  }

  String islemonubakiye(i) {
    double musbak = widget.musteri.kisi_borcu;
    double anlikbakiye = musbak;
    List<String> budgetl;
    String txt = "";
    for (int i = 0; i < filteredList.length; i++) {
      String metin = filteredList[i][0];
      budgetl = metin.split("TL");
      double budgetr = double.parse(budgetl[0]);
      if (filteredList[i][2] == "ALACAK") {
        anlikbakiye = anlikbakiye + budgetr;
      } else {
        anlikbakiye = anlikbakiye - budgetr;
      }
      if (anlikbakiye == 0)
        txt = "";
      else
        txt = "İşlem Önü Bakiye\n${anlikbakiye.toString()}TL";
      filteredList[i].add(txt);
    }
    return filteredList[i][3];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Container(
              height: 440,
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    dropdownValueLeading = "TÜMÜ";
                    dropdownValueZaman = "TÜMÜ";
                    filterList();
                  });
                },
                child: ListView.builder(
                  itemBuilder: (context, i) {
                    return Card(
                      margin: const EdgeInsets.all(4),
                      elevation: 8,
                      child: ListTile(
                        leading: Text(
                          filteredList[i][2],
                          style: TextStyle(
                              fontSize: 12,
                              color: filteredList[i][2] == "BORÇ"
                                  ? Colors.red
                                  : Colors.green),
                        ),
                        title: Text(
                          filteredList[i][0],
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: Text(
                          islemonubakiye(i).replaceAll(regex, ''),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                  itemCount: filteredList.length,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [BackButton(), dropDown(), dropDownZaman()],
      ),
    );
  }
}
