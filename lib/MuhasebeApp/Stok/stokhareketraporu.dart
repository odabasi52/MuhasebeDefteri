import 'package:flutter/material.dart';

/*My Libs*/
import 'malzemeler.dart';
import '../CommonUsed/Functions.dart';

class HarekerRaporPage extends StatefulWidget {
  HarekerRaporPage({super.key, required this.child});
  ChildMalzemeler child;

  @override
  State<HarekerRaporPage> createState() => _HarekerRaporPageState();
}

class _HarekerRaporPageState extends State<HarekerRaporPage> {
  List<HareketRaporu> hareketler = [];
  List<HareketRaporu> filteredHareketler = [];

  String timeConverter(DateTime tarih) {
    return "${tarih.day}/${tarih.month}/${tarih.year} - ${tarih.hour}.${tarih.second}";
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  DateTime date_start = DateTime(2022);
  DateTime date_end = DateTime(2022);
  void OpenTakvim() async {
    DateTimeRange? dates = await showDateRangePicker(
        context: context, firstDate: DateTime(2022), lastDate: DateTime(2050));
    if (dates != null) {
      date_start = dates.start;
      date_end = dates.end;

      setState(() {
        filteredHareketler = hareketler.where((element) {
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
        }).toList();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hareketler = HareketRaporu.decode(widget.child.hareketRaporu);
    filteredHareketler = hareketler;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: OpenTakvim, child: Text("TAKVİM"))
        ],
      ),
      appBar: AppBar(
        title: Text("${widget.child.anaMalzeme} - ${widget.child.childIsim}"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            filteredHareketler = hareketler;
          });
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: ListView.builder(
            itemBuilder: (context, i) {
              return Card(
                margin: const EdgeInsets.all(4),
                elevation: 8,
                child: ListTile(
                  title: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(filteredHareketler[i].rapor.replaceAll(regex, '')),
                  ),
                  subtitle: Text(timeConverter(
                      DateTime.parse(filteredHareketler[i].tarih))),
                  trailing: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text("STOK: ${filteredHareketler[i].anlikStok.toString().replaceAll(regex, '')}KG"),
                  ),
                ),
              );
            },
            itemCount: filteredHareketler.length,
          ),
        ),
      ),
    );
  }
}
