import 'package:flutter/material.dart';

/*My Libs*/
import '../CariPage/Cari/hesapcuzdan.dart';
import '../CommonUsed/Functions.dart';

/*Others*/
import 'pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KasaBakiyePage extends StatefulWidget {
  const KasaBakiyePage({super.key});

  @override
  State<KasaBakiyePage> createState() => _KasaBakiyePageState();
}

class _KasaBakiyePageState extends State<KasaBakiyePage> {
  double bakiyenakit = 0;
  double bakiyeiban = 0;
  double toplambakiye = 0;
  double toplambakiyef(bakiyenakit, bakiyeiban) {
    double toplambakiye = bakiyenakit + bakiyeiban;
    return toplambakiye;
  }

  List<Cuzdan> odemeler = [];
  List<Cuzdan> filteredOdemeler = [];
  void bakiye_hesap() {
    for (Cuzdan odeme in filteredOdemeler) {
      //dijital
      if (odeme.kart) {
        //Odeme yapıldı
        if (!odeme.eksildi) {
          bakiyeiban -= odeme.odenen;
        }
        //Odeme alındı
        else {
          bakiyeiban += odeme.odenen;
        }
      }
      //nakit
      else {
        if (!odeme.eksildi) {
          bakiyenakit -= odeme.odenen;
        }
        //Odeme alındı
        else {
          bakiyenakit += odeme.odenen;
        }
      }
    }
  }

  void getKasaOdeme() async {
    final prefs = await SharedPreferences.getInstance();
    String? odemeString = prefs.getString("kasa_ödemeler");
    if (odemeString == "" || odemeString == null || odemeString == " ") {
      odemeler = [];
    } else {
      odemeler = Cuzdan.decode(odemeString);
    }
    //deafult günlük
    setState(() {
      filteredOdemeler = odemeler.where(
        (element) {
          DateTime date = DateTime.parse(element.tarih);
          int days = daysBetween(date, DateTime.now());
          if (days < 1) {
            return true;
          } else {
            return false;
          }
        },
      ).toList();
      bakiye_hesap();
    });
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
        context: context, firstDate: DateTime(2022), lastDate: DateTime(2050));
    if (dates != null) {
      date_start = dates.start;
      date_end = dates.end;
    }
    setState(() {
      filteredOdemeler = odemeler.where(
        (element) {
          DateTime date = DateTime.parse(element.tarih);
          int days_fatura_tarihi = daysBetween(DateTime(2022), date);
          int days_start = daysBetween(DateTime(2022), date_start);
          int days_end = daysBetween(DateTime(2022), date_end);
          if (days_fatura_tarihi <= days_end &&
              days_fatura_tarihi >= days_start) {
            return true;
          } else {
            return false;
          }
        },
      ).toList();

      bakiyenakit = 0;
      bakiyeiban = 0;
      bakiye_hesap();
    });
  }

  @override
  void initState() {
    super.initState();
    getKasaOdeme();
  }

  @override
  Widget build(BuildContext context) {
    toplambakiye = toplambakiyef(bakiyenakit, bakiyeiban);
    final List<DataPoint> data = [
      DataPoint(
          value: bakiyeiban.abs(),
          title: bakiyeiban > 0 ? 'DİJİTAL (+)' : 'DİJİTAL (-)',
          color: bakiyeiban > 0 ? Colors.blue : Colors.red),
      DataPoint(
          value: bakiyenakit.abs(),
          title: bakiyenakit > 0 ? 'NAKİT (+)' : 'NAKİT (-)',
          color: bakiyenakit > 0 ? Colors.green : Colors.redAccent),
    ];
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACCCC),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(100, 0, 0, 0),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text("Mevcut Bakiye",
                          style: DefaultTextStyle.of(context)
                              .style
                              .apply(fontSizeFactor: 2.0)),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Nakit Bakiye",
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.2)),
                            Text("${add_comma_to_double(bakiyenakit).replaceAll(regex, '')} TL",
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.2)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Dijital Bakiye",
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.2)),
                            Text("${add_comma_to_double(bakiyeiban).replaceAll(regex, '')} TL",
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.2)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Toplam Bakiye",
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.2)),
                            Text("${add_comma_to_double(toplambakiye).replaceAll(regex, '')} TL",
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 2.0,
                          child: PieChartWidget(data),
                        )
                      ],
                    )),
              ),
            ],
          )
        ],
      ),
      bottomSheet:
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton(
            onPressed: OpenTakvim,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
            child: Text("TAKVİM")),
        ElevatedButton(
            onPressed: () => setState(() {
                  bakiyenakit = 0;
                  bakiyeiban = 0;
                  filteredOdemeler = odemeler;
                  bakiye_hesap();
                }),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
            child: Text("TÜMÜ")),
      ]),
    );
  }
}
