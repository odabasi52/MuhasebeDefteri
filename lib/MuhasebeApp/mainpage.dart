import 'package:flutter/material.dart';

/*My Libs*/
import 'CariPage/Cari/caripage.dart';
import 'AlisSatisPage/alis_satis_page.dart';
import 'Kasa/kasamain.dart';
import 'Stok/stokpage.dart';
import 'CommonUsed/CurvedAppBar.dart';
import 'Ayarlar/ayarlar.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future<bool>.value(false);
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipPath(
                clipper: BackgroundWaveClipper(),
                child: Container(
                  child: Image.asset("images/launcher_icon.png"),
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
                children: [
                  //Cari Button
                  ElevatedButton(
                    onPressed: () => setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CariPage()),
                      );
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_2_rounded, size: 33),
                        Text("CARİ", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    style: ButtonStyle(
                        shadowColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.white),
                        fixedSize: MaterialStateProperty.all(Size(120, 120))),
                  ),

                  //Alış Button
                  ElevatedButton(
                    onPressed: () => setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlisSatisPage(satis: false)),
                      );
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.attach_money, size: 33),
                        Text("ALIŞ", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    style: ButtonStyle(
                        shadowColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.white),
                        fixedSize: MaterialStateProperty.all(Size(120, 120))),
                  )
                ],
              ),
              Divider(
                height: 30,
                color: Colors.white,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //SATIŞ Button
                  ElevatedButton(
                    onPressed: () => setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlisSatisPage(satis: true)),
                      );
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sell, size: 33),
                        Text("SATIŞ", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    style: ButtonStyle(
                        shadowColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.white),
                        fixedSize: MaterialStateProperty.all(Size(120, 120))),
                  ),

                  //STOK Button
                  ElevatedButton(
                    onPressed: () => setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StokPage()),
                      );
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_mall_directory, size: 33),
                        Text("STOK", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    style: ButtonStyle(
                        shadowColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.white),
                        fixedSize: MaterialStateProperty.all(Size(120, 120))),
                  ),
                ],
              ),
              Divider(
                height: 30,
                color: Colors.white,
              ),
              //KASA Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Kasa_Demo()),
                      );
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance, size: 33),
                        Text("KASA", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    style: ButtonStyle(
                        shadowColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.white),
                        fixedSize: MaterialStateProperty.all(Size(120, 120))),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AyarPage()),
                      );
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, size: 33),
                        Text("AYARLAR", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    style: ButtonStyle(
                        shadowColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.white),
                        fixedSize: MaterialStateProperty.all(Size(120, 120))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
