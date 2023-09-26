import 'package:flutter/material.dart';

/*My Libs*/
import 'kasa_guncelle.dart';
import 'malzemeler_page.dart';
import 'stokpage.dart';

class IslemAyarlar extends StatefulWidget {
  const IslemAyarlar({super.key});

  @override
  State<IslemAyarlar> createState() => _IslemAyarlarState();
}

class _IslemAyarlarState extends State<IslemAyarlar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Ayarlar"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_sharp),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StokPage()),
                );
              },
            ),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.local_mall_rounded), text: 'Malzemeler'),
                Tab(icon: Icon(Icons.cases_rounded), text: 'Kasa'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              MalzemelerPage(),
              KasaPage(),
            ],
          )),
    );
  }
}
