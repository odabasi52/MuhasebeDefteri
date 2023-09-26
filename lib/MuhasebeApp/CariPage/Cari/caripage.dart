import 'package:flutter/material.dart';

/*My Libs*/
import 'package:muhasebe/MuhasebeApp/CariPage/Cari/hesapcuzdan.dart';
import 'package:muhasebe/MuhasebeApp/CariPage/Cari/user_dialog.dart';
import 'package:muhasebe/MuhasebeApp/CariPage/Cari/user.dart';
import 'package:muhasebe/MuhasebeApp/CariPage/Cari/carirapor.dart';
import 'package:muhasebe/MuhasebeApp/CariPage/Faturalar/faturalar.dart';
import 'package:muhasebe/MuhasebeApp/CommonUsed/Functions.dart';
import 'package:muhasebe/MuhasebeApp/mainpage.dart';

/*Others*/
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CariPage extends StatefulWidget {
  const CariPage({super.key});

  @override
  State<CariPage> createState() => _CariPageState();
}

class _CariPageState extends State<CariPage> {
  List<User> musteriList = [];
  List<User> filteredMusteriList = [];

  @override
  void initState() {
    super.initState();
    LoadMusteriList();
  }

  Future<void> SaveMusteriList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = User.encode(musteriList);
    await prefs.setString("musteriler", encodedData);
  }

  void LoadMusteriList() async {
    final prefs = await SharedPreferences.getInstance();
    String? musteriString = prefs.getString("musteriler");

    setState(() {
      if (musteriString == " " || musteriString == null) {
        musteriList = [];
        filteredMusteriList = musteriList;
      } else {
        musteriList = User.decode(musteriString.toString());
        filteredMusteriList = musteriList;
      }
    });
  }

  void addMusteri(User user) {
    RegExp telefon = RegExp(r"05\d{9}$");
    if (musteriList.map((item) => item.id).contains(user.id)) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Kişi Kaydı Bulunmaktadır.',
        ),
      );
    } else if (user.id.length != 11 ||
        int.tryParse(user.id) == null ||
        int.parse(user.id) <= 0) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Musteri ID Hatalı",
        ),
      );
    } else if (!telefon.hasMatch(user.telefon)) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Telefon Hatalı",
        ),
      );
    } else if (user.username.replaceAll(" ", "") == "") {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Müşteri Adı Hatalı",
        ),
      );
    } else {
      musteriList.add(user);
      SaveMusteriList();
      LoadMusteriList();
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: "Kişi Ekleme Başarılı\n${user.username}",
        ),
      );
    }
  }

  int removed_index = 0;
  void removeMusteri(index) {
    setState(() {
      for (int i = 0; i < musteriList.length; i++) {
        if (musteriList[i].id == filteredMusteriList[index].id) {
          musteriList.removeAt(i);
          removed_index = i;
        }
      }

      SaveMusteriList();
      LoadMusteriList();
    });
  }

  void undoDelete(index, musteri) {
    musteriList.insert(removed_index, musteri);
    SaveMusteriList();
    LoadMusteriList();
  }

  void showUserDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: AddUserDia(addMusteri),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        });
  }

  Widget filteringTextField() {
    return Container(
      margin: const EdgeInsets.all(4),
      child: SizedBox(
        height: 45,
        width: double.infinity,
        child: TextField(
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_search_rounded),
            labelText: "İsim - Musteri ID - Telefon No",
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black45,
              ),
            ),
          ),
          controller: TextEditingController(),
          onSubmitted: searchMusteri,
        ),
      ),
    );
  }

  void searchMusteri(String query) {
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
    setState(() => filteredMusteriList = suggestion);
  }

  void showDeleteDialog(content) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: content,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        });
  }

  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String Function(Match) mathFunc = (Match match) => '${match[1]},';
  String bakiyemetni(i) {
    String bakiyemetni = filteredMusteriList[i].kisi_borcu > 0
        ? filteredMusteriList[i]
                .kisi_borcu
                .toString()
                .replaceAllMapped(reg, mathFunc) +
            "TL\tBorçlu"
        : filteredMusteriList[i]
                .kisi_borcu
                .toString()
                .replaceAllMapped(reg, mathFunc) +
            "TL\tAlacaklı";
    return bakiyemetni;
  }

  Widget deletePopUp(i) {
    return StatefulBuilder(builder: (context, setStateSB) {
      return Container(
        padding: const EdgeInsets.all(8),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () => setStateSB(() {
                      removeMusteri(i);
                      Navigator.of(context).pop();
                    }),
                child: Text("SİL")),
            ElevatedButton(
                onPressed: () => setStateSB(() {
                      LoadMusteriList();
                      Navigator.of(context).pop();
                    }),
                child: Text("İPTAL")),
          ],
        ),
      );
    });
  }

  int current_index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: showUserDialog,
        child: const Icon(
          Icons.person_add_alt_1,
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          },
        ),
        title: const Text("Cari"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            filteringTextField(),
            Container(
              height: MediaQuery.of(context).size.height * 0.68,
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    LoadMusteriList();
                  });
                },
                child: ListView.builder(
                  itemBuilder: (context, i) {
                    return Dismissible(
                      //Slide Left to Delete
                      direction: DismissDirection.endToStart,
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        if (!(musteriList[i].faturaString == " " ||
                            musteriList[i].faturaString == "[]")) {
                          showTopSnackBar(
                            Overlay.of(context),
                            const CustomSnackBar.error(
                              message: 'Kişiye Ait Fatura Bulunmaktadır',
                            ),
                          );
                          LoadMusteriList();
                        } else if (!(musteriList[i].cuzdanString == " " ||
                            musteriList[i].cuzdanString == "[]")) {
                          showTopSnackBar(
                            Overlay.of(context),
                            const CustomSnackBar.error(
                              message: 'Kişiye Ait Ödeme Bulunmaktadır',
                            ),
                          );
                          LoadMusteriList();
                        } else {
                          showDeleteDialog(deletePopUp(i));
                        }
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.person_remove_alt_1_rounded,
                          color: Colors.white,
                        ),
                      ),

                      //Showing List Elements
                      child: Card(
                        margin: const EdgeInsets.all(4),
                        elevation: 8,
                        child: ListTile(
                          onLongPress: () => setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CariRapor(musteri: musteriList[i])),
                            );
                          }),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.receipt_sharp,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () => setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FaturaSayfasi(
                                        musteri: filteredMusteriList[i],
                                        musteriler: musteriList)),
                              );
                            }),
                          ),
                          leading: IconButton(
                            icon: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () => setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HesapCuzdan(
                                          musteri: musteriList[i],
                                          musteriler: musteriList,
                                        )),
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
                            "Bakiye: " +
                                bakiyemetni(i)
                                    .replaceAll("-", "")
                                    .replaceAll(regex, ''),
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black45,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: filteredMusteriList.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
