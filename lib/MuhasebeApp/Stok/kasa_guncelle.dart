import 'package:flutter/material.dart';

/*Others*/
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class KasaPage extends StatefulWidget {
  const KasaPage({super.key});

  @override
  State<KasaPage> createState() => _KasaPageState();
}

class _KasaPageState extends State<KasaPage> {
  double kasaKgDouble = 2;
  var KasaKg = TextEditingController();

  Future<void> SaveKasaKg() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("kasakg", kasaKgDouble);
  }

  void LoadKasaKg() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      kasaKgDouble = prefs.getDouble("kasakg") ?? 2;
    });
  }

  @override
  void initState() {
    super.initState();
    LoadKasaKg();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: RichText(
                text: TextSpan(
              children: <TextSpan>[
                const TextSpan(
                    text: 'Boş Kasa KG: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17)),
                TextSpan(
                    text: "$kasaKgDouble kg",
                    style: TextStyle(color: Colors.black, fontSize: 15)),
              ],
            )),
          ),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: TextField(
              maxLength: 4,
              onSubmitted: (value) {
                setState(() {
                  if (double.tryParse(KasaKg.text) != null &&
                      double.parse(KasaKg.text) > 0) {
                    kasaKgDouble = double.parse(KasaKg.text);
                    SaveKasaKg();
                  } else if (double.tryParse(KasaKg.text) == null) {
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.error(
                        message: 'Tam sayı veya noktalı sayı giriniz.',
                      ),
                    );
                  } else if (double.parse(KasaKg.text) <= 0) {
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.error(
                        message: 'Kilogram değeri negatif olamaz',
                      ),
                    );
                  }
                });
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Boş Kasa KG Güncelle",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black45,
                  ),
                ),
              ),
              controller: KasaKg,
            ),
          ),
        ],
      ),
    );
  }
}
