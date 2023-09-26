import 'package:flutter/material.dart';

/*My Libs*/
import 'beklenen_bakiye.dart';
import 'kasa_bakiye.dart';
import 'kasaakisraporu.dart';

/*Others*/
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class Kasa_Demo extends StatelessWidget {
  const Kasa_Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Kasa"),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(
                  icon: Icon(Icons.access_time_filled_sharp),
                  text: 'Akış Raporu'),
              Tab(
                  icon: Icon(Icons.account_balance_wallet_sharp),
                  text: 'Kasa Bakiye'),
              Tab(
                  icon: Icon(FontAwesomeIcons.cashRegister),
                  text: 'Gelecek Bakiye'),
            ],
          ),
        ),
        body: TabBarView(
          children: [KasaPage(), KasaBakiyePage(), BeklenenPage()],
        ),
      ),
    );
  }
}
