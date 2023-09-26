import 'package:flutter/material.dart';

/*My Lib*/
import '../CommonUsed/CurvedAppBar.dart';
import 'alis_satis_rapor.dart';
import '../CariPage/Cari/user.dart';
import '../CariPage/Faturalar/faturalar.dart';
import '../CariPage/islemler/islemler_sayfasi.dart';
import '../CommonUsed/Functions.dart';

/*Others*/
import 'package:shared_preferences/shared_preferences.dart';

class AlisSatisPage extends StatefulWidget {
  AlisSatisPage({super.key, required this.satis});
  bool satis;

  @override
  State<AlisSatisPage> createState() => _AlisSatisPageState();
}

class _AlisSatisPageState extends State<AlisSatisPage> {
  void KisiSecDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setSB) {
              return AlertDialog(
                content: KisiSecPopUp(setSB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }
          );
        });
  }

  
  List <User> filteredMusteriList = [];
  int x = 0;
  var KisiController = TextEditingController();
  Widget KisiSecPopUp(SetSB) {
    if (x == 0) {
      x++;
      SetSB(() {
        filteredMusteriList = kisiler;
      });
    }
    return RefreshIndicator(
      onRefresh: ()async{
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
            height: 200,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: filteredMusteriList.length,
              itemBuilder: (_, i) {
                return ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.person_outline_rounded, color: Colors.pink,),
                    onPressed: () {
                      setState(() {
                        AlisEkle(i, context);
                      });
                    },
                  ),
                  title: Text(
                    filteredMusteriList[i].username,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Borç: " + add_comma_to_double(filteredMusteriList[i].kisi_borcu.toString().replaceAll(regex, '')) + "TL",
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

  void AlisEkle(i, contxt) {
    // ignore: prefer_interpolation_to_compose_strings
    final fatura = Faturalar(" ", DateTime.now().toString(), widget.satis, "0.0", null);
    List<Faturalar> faturaList = [];
    if(filteredMusteriList[i].faturaString == "" || filteredMusteriList[i].faturaString == " "){

    }else{
      faturaList = Faturalar.decode(filteredMusteriList[i].faturaString); 
    }
     
    setState(() {
      faturaList.insert(0, fatura);
      SaveFaturaList(faturaList, i);
      SaveMusteriList();
    });

    Navigator.of(contxt).pop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IslemlerSayfasi(
          fatura: faturaList[0],
          faturaList: faturaList,
          musteri: filteredMusteriList[i],
          musteriler: kisiler,
        ),
      ),
    );
  }

  void LoadMusteriList() async {
    final prefs = await SharedPreferences.getInstance();
    String? musteriString = prefs.getString("musteriler");

    setState(() {
      if (musteriString == " " || musteriString == null) {
        kisiler = [];
      } else {
        kisiler = User.decode(musteriString.toString());
      }
    });
  }

  Future<void> SaveMusteriList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = User.encode(kisiler);
    await prefs.setString("musteriler", encodedData);
  }

  Future<void> SaveFaturaList(faturaList, i) async {
    final String encodedData = Faturalar.encode(faturaList);
    filteredMusteriList[i].faturaString = encodedData;
  }

  List<User> kisiler = [];
  @override
  void initState() {
    super.initState();
    LoadMusteriList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: BackButton(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: BackgroundWaveClipper(),
              child: Container(
                child: widget.satis
                    ? Image.asset("images/sell.png", scale: 1.5)
                    : Image.asset("images/buy.png", scale: 1.5),
                padding: EdgeInsets.all(50),
                width: MediaQuery.of(context).size.width,
                height: 280,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Color(0xFFFACCCC), Color(0xFFF6EFE9)],
                )),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RaporPage(satis: widget.satis)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_document, size: 33),
                  Text(widget.satis ? "SATIŞ RAPORU" : "ALIŞ RAPORU",
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              style: ButtonStyle(
                  shadowColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.white),
                  fixedSize: MaterialStateProperty.all(Size(120, 120))),
            ),
            Divider(
              height: 30,
              color: Colors.white,
            ),
            ElevatedButton(
              onPressed: () => setState(() => KisiSecDialog()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add_rounded, size: 33),
                  Text(widget.satis ? "SATIŞ EKLE" : "ALIŞ EKLE",
                      style: TextStyle(fontSize: 14)),
                ],
              ),
              style: ButtonStyle(
                  shadowColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.white),
                  fixedSize: MaterialStateProperty.all(Size(120, 120))),
            ),
          ],
        ),
      ),
    );
  }
}
