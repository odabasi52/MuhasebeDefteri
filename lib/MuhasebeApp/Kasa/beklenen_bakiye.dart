import 'package:flutter/material.dart';

/*My Libs*/
import '../CariPage/Cari/user.dart';
import '../CommonUsed/Functions.dart';

/*Others*/
import 'pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';



class BeklenenPage extends StatefulWidget {
  const BeklenenPage({super.key});
  @override
  State<BeklenenPage> createState() => _BeklenenPageState();
}

class _BeklenenPageState extends State<BeklenenPage> {
  List<User> musteriList = [];
  List<User> filteredMusteriList = [];
  double bakiyealacak = 0;
  double bakiyeborc = 0;
  //bakiye borç benim kasamdan çıkacak para
  //bakiye alacak benim kasama girecek para
  double toplambakiye = 0.0;

  double toplambakiyef(bakiyealacak, bakiyeborc) {
    double toplambakiye = bakiyealacak - bakiyeborc;
    return toplambakiye;
  }

  double getabs(double) {
    double = double.abs();
    return double;
  }

  String toplambakiyetext(double bakiye) {
    String text;
    if (bakiye < 0) {
      text = "Kasanızdan ${add_comma_to_double(bakiye.abs())}TL çıkış bekleniyor";
    } else if (bakiye == 0) {
      text = "Kasanızın beklenen kar ve gideri yok";
    } else {
      text = "Kasanıza ${add_comma_to_double(bakiye.abs())}TL giriş bekleniyor";
    }
    return text;
  }

  void getBakiye() async {
    final prefs = await SharedPreferences.getInstance();
    String? musteriString = prefs.getString("musteriler");

    setState(() {
      if (musteriString == " " || musteriString == null) {
        musteriList = [];
        filteredMusteriList = musteriList;
      } else {
        musteriList = User.decode(musteriString.toString());
        filteredMusteriList = musteriList;
        bakiyealacak = 0;
        bakiyeborc = 0;
        GelecekBakset();
        bakiyeborc = getabs(bakiyeborc);
      }
    });
  }

  void GelecekBakset() {
    for (User user in filteredMusteriList) {
      if (user.kisi_borcu < 0) {
        bakiyeborc += user.kisi_borcu;
      } else {
        bakiyealacak += user.kisi_borcu;
      }
    }
  }

  late double bakiyetoplam;
  @override
  void initState() {
    super.initState();
    getBakiye();
  }

  @override
  Widget build(BuildContext context) {
    toplambakiye = toplambakiyef(bakiyealacak, bakiyeborc);
    final List<DataPoint> data = [
      DataPoint(value: bakiyeborc, title: 'Nakit', color: Colors.blue),
      DataPoint(value: bakiyealacak, title: 'Dijital', color: Colors.green),
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
                      Text("Beklenen Bakiye",
                          style: DefaultTextStyle.of(context)
                              .style
                              .apply(fontSizeFactor: 2.0)),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Borç",
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.2)),
                            Text("${add_comma_to_double(bakiyeborc).replaceAll(regex, '')} TL",
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
                              Text("Alacak",
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .apply(fontSizeFactor: 1.2)),
                              Text("${add_comma_to_double(bakiyealacak).replaceAll(regex, '')} TL",
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .apply(fontSizeFactor: 1.2)),
                            ],
                          )),
                      Divider(height: 20,color: Colors.black,),
                      Container(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(toplambakiyetext(toplambakiye).replaceAll(regex, ''),
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .apply(fontSizeFactor: 1.2))),
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
    );
  }
}
