import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = new http.Client();

  GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class AyarPage extends StatefulWidget {
  const AyarPage({super.key});

  @override
  State<AyarPage> createState() => _AyarPageState();
}

class _AyarPageState extends State<AyarPage> {

  Future<void> _uploadData() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {}
    } on SocketException catch (_) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "İnternet Bağlantınızı Kontrol Ediniz",
        ),
      );
      return;
    }

    final googleSignIn = signIn.GoogleSignIn.standard(
        scopes: [drive.DriveApi.driveAppdataScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
    final authHeaders = await account!.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    final prefs = await SharedPreferences.getInstance();
    final musteriString = await prefs.getString("musteriler") ?? "[]";
    final anaMalzemeString = await prefs.getString("AnaMalzemeler") ?? "[]";
    final kasaString = await prefs.getString("kasa_ödemeler") ?? "[]";
    final kasaEkString = await prefs.getString("ekstra_ödemeler") ?? "[]";
    List<Saver> save = [
      Saver(musteriString, anaMalzemeString, kasaString, kasaEkString)
    ];
    String saveString = Saver.encode(save);
    final Stream<List<int>> mediaStream =
        Future.value(saveString.toString().codeUnits).asStream();
    var media = new drive.Media(mediaStream, saveString.toString().length);
    var driveFile = new drive.File();
    final timestamp = DateTime.now();
    final name =
        "${timestamp.day.toString()}/${timestamp.month.toString()}/${timestamp.year.toString()}" +
            " - " +
            timestamp.hour.toString() +
            "." +
            timestamp.minute.toString();

    driveFile.name = name;
    driveFile.parents = ["appDataFolder"];

    await driveApi.files.create(driveFile, uploadMedia: media);
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: "Verileriniz Buluta Yedeklendi.",
      ),
    );
  }

  Future<void> _readData() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {}
    } on SocketException catch (_) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "İnternet Bağlantınızı Kontrol Ediniz",
        ),
      );
      return;
    }

    final googleSignIn = signIn.GoogleSignIn.standard(
        scopes: [drive.DriveApi.driveAppdataScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();

    final authHeaders = await account!.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    final fileList = await driveApi.files.list(
        spaces: 'appDataFolder', $fields: 'files(id, name, modifiedTime)');
    final files = fileList.files;
    if (files == null || files.length == 0) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Yedek Bulunmamaktadır.",
        ),
      );
    } else {
      var last_5 = [];
      switch (files.length) {
        case 1:
          last_5 = [files[0]];
          break;
        case 2:
          last_5 = [
            files[0],
            files[1],
          ];
          break;
        case 3:
          last_5 = [
            files[0],
            files[1],
            files[2],
          ];
          break;
        case 4:
          last_5 = [
            files[0],
            files[1],
            files[2],
            files[3],
          ];
          break;
        default:
          last_5 = [files[0], files[1], files[2], files[3], files[4]];
          break;
      }

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: last_5.length,
                  itemBuilder: (_, i) {
                    return ListTile(
                      leading: IconButton(
                        icon: Icon(
                          Icons.cloud_download,
                          color: Colors.pink,
                        ),
                        onPressed: () async {
                          drive.Media response = await driveApi.files.get(
                              last_5[i].id.toString(),
                              downloadOptions: drive
                                  .DownloadOptions.fullMedia) as drive.Media;

                          List<int> dataStore = [];
                          response.stream.listen((data) {
                            dataStore.insertAll(dataStore.length, data);
                          }, onDone: () async {
                            Directory tempDir =
                                await getTemporaryDirectory(); //Get temp folder using Path Provider
                            String tempPath =
                                tempDir.path; //Get path to that location
                            File file =
                                File('$tempPath/test'); //Create a dummy file
                            await file.writeAsBytes(
                                dataStore); //Write to that file from the datastore you created from the Media stream
                            String content = file
                                .readAsStringSync(); // Read String from the file

                            final prefs = await SharedPreferences.getInstance();

                            List<Saver> saves = Saver.decode(content);
                            await prefs.setString(
                                "AnaMalzemeler", saves[0].anaMalzemeString);
                            await prefs.setString(
                                "musteriler", saves[0].musteriString);
                            await prefs.setString(
                                "kasa_ödemeler", saves[0].kasaString);
                            await prefs.setString(
                                "ekstra_ödemeler", saves[0].kasaEkString);
                            setState(() {
                              showTopSnackBar(
                                Overlay.of(context),
                                const CustomSnackBar.success(
                                  message:
                                      "Verileriniz Buluttan Başarı ile Çekildi",
                                ),
                              );
                              Navigator.pop(context);
                            });
                          }, onError: (error) {});
                        },
                      ),
                      title: Text(
                        last_5[i].name ?? "",
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  },
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("AYARLAR"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _uploadData,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload, size: 33),
                      Text("YEDEKLE", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  style: ButtonStyle(
                      shadowColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(120, 120))),
                ),
                ElevatedButton(
                  onPressed: _readData,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, size: 33),
                      Text("YEDEKTEN AL", style: TextStyle(fontSize: 13)),
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
        ));
  }
}

class Saver {
  String musteriString;
  String anaMalzemeString;
  String kasaString;
  String kasaEkString;

  Saver(this.musteriString, this.anaMalzemeString, this.kasaString,
      this.kasaEkString);

  factory Saver.fromJson(Map<String, dynamic> jsonData) {
    return Saver(
      jsonData['musteriString'],
      jsonData['anaMalzemeString'],
      jsonData['kasaString'],
      jsonData['kasaEkString'],
    );
  }

  static Map<String, dynamic> toMap(Saver malzeme) => {
        'musteriString': malzeme.musteriString,
        'anaMalzemeString': malzeme.anaMalzemeString,
        'kasaString': malzeme.kasaString,
        'kasaEkString': malzeme.kasaEkString,
      };

  static String encode(List<Saver> malzemeler) => json.encode(
        malzemeler
            .map<Map<String, dynamic>>((malzeme) => Saver.toMap(malzeme))
            .toList(),
      );

  static List<Saver> decode(String malzemeler) =>
      (json.decode(malzemeler) as List<dynamic>)
          .map<Saver>((malzeme) => Saver.fromJson(malzeme))
          .toList();
}