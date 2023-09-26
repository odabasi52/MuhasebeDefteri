import 'package:flutter/material.dart';

/*My Libs*/
import 'user.dart';
import '../../CommonUsed/Functions.dart';

class AddUserDia extends StatefulWidget {
  final Function(User) addMusteri;
  const AddUserDia(this.addMusteri);

  @override
  State<AddUserDia> createState() => _AddUserDiaState();
}

class _AddUserDiaState extends State<AddUserDia> {
  String musteriTxt = "";
  String babaTxt = "";
  String tcTxt = "";
  String telTxt = "";
  String adresTxt = "";

  var Musteri_adi = TextEditingController();
  var Baba_adi = TextEditingController();
  var ID = TextEditingController();
  var Telefon = TextEditingController();
  var Adres = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    Musteri_adi.text = musteriTxt;
    Baba_adi.text = babaTxt;
    ID.text = tcTxt;
    Telefon.text = telTxt;
    Adres.text = adresTxt;
    

    Widget BuildTextField(String hint, TextEditingController controller, bool text) {
      return Container(
        margin: const EdgeInsets.all(4),
        child: SizedBox(
          width: 280,
          child: TextField(
            maxLines: 1,
            keyboardType: text ? TextInputType.name : TextInputType.number,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
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

    return Container(
      padding: const EdgeInsets.all(8),
      height: 295,
      width: 400,
      child: Column(
        children: [

          BuildTextField("Müşteri Adı", Musteri_adi, true),
          BuildTextField("Müşteri ID", ID, false),
          BuildTextField("Telefon No", Telefon, false),
          Row(
            children: [
                Expanded(
                    child: Divider()
                ),       
                Text("isteğe bağlı", style: TextStyle(color: Colors.black38, fontSize: 11),),        
                Expanded(
                    child: Divider()
                ),
            ]
          ),
          BuildTextField("Baba Adı", Baba_adi, true),
          BuildTextField("Adres", Adres, true),
          

          ElevatedButton(
            onPressed: () {
              final user = User(replacedString(Musteri_adi.text.trim()).toUpperCase() , ID.text.trim(),
                 replacedString(Baba_adi.text.trim()).toUpperCase(), Telefon.text.trim(), replacedString(Adres.text.trim()), " ", 0, " ");
              setState(() {
                  musteriTxt = Musteri_adi.text;
                  babaTxt = Baba_adi.text;
                  tcTxt = ID.text;
                  telTxt = Telefon.text;
                  adresTxt = Adres.text;
                  widget.addMusteri(user);
                  Navigator.pop(context);
              });
            },
            child: Text("Kişi Ekle"),
          ),
        ],
      ),
    );
  }
}
