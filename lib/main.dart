import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muhasebe/MuhasebeApp/mainpage.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:io';
import 'MuhasebeApp/CommonUsed/CurvedAppBar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Step 3
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(MaterialApp(
        theme: ThemeData(primarySwatch: createMaterialColor(Color(0xFFFACCCC))),
        debugShowCheckedModeBanner: false,
        home: FirstEnterance(),
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('tr', 'TR')],
      )));
}

class FirstEnterance extends StatefulWidget {
  const FirstEnterance({super.key});

  @override
  State<FirstEnterance> createState() => _FirstEnteranceState();
}

class _FirstEnteranceState extends State<FirstEnterance> {
  Widget BuildTextField(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: SizedBox(
        width: double.infinity,
        child: TextField(
          maxLines: 1,
          maxLength: 20,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(15),
            isDense: true,
            labelText: hint,
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black45,
              ),
            ),
          ),
          controller: controller,
        ),
      ),
    );
  }

  @override
  void initState()
  {
    super.initState();
    checkIfValid();
  }

  void checkIfValid() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dahaOnceGirdi = prefs.getBool("dahaOnceGirdi")??false;
    if(!dahaOnceGirdi){return ;}
    else
    {
      goMain();
    }
  }

  void saveValid()async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dahaOnceGirdi", true);
  }

  void Enter() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {}
    } on SocketException catch (_) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: "İnternet Bağlantınızı Kontrol Ediniz",
        ),
      );
      return;
    }
    if (Parola.text.trim() == "") {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Parola Giriniz",
        ),
      );
      return;
    }
    await Firebase.initializeApp();
    DocumentReference doc =
        FirebaseFirestore.instance.collection("Muhasebe").doc("MuhasebeDoc");
    doc.get().then((document) {
      print(document.data());
      var data = document.data() as Map<String, dynamic>;
      getID(doc);
      if (data["${Parola.text}"] == null) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Parola Geçersiz",
          ),
        );
      } else if (data["${Parola.text}"] == "") {
        updateID(doc);
        saveValid();
        goMain();
      } else if (data["${Parola.text}"] == ID) {
        saveValid();
        goMain();
      }
    });
  }

  void goMain() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  String ID = "";
  void getID(doc) async {
    var deviceInfo = DeviceInfoPlugin();
    var androidDeviceInfo = await deviceInfo.androidInfo;
    ID = androidDeviceInfo.fingerprint;
  }

  void updateID(doc) async {
    var deviceInfo = DeviceInfoPlugin();
    var androidDeviceInfo = await deviceInfo.androidInfo;
    doc.update({"${Parola.text}": androidDeviceInfo.fingerprint});
  }

  TextEditingController Parola = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future<bool>.value(false);
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Divider(height: 35, color: Colors.white,),
            BuildTextField("PAROLA", Parola),
            ElevatedButton(onPressed: Enter, child: Text("GIRIS YAP")),
          ],
        ),
      ),
    );
  }
}
