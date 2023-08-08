import 'dart:convert';
import 'dart:io';

import 'package:find_hotel/routes/route_names.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../api/encrypt.dart';
import '../../urls/all_url.dart';
import '../../utils/localfiles.dart';
import '../../widgets/custom_apbar.dart';
import 'package:http/http.dart' as http;

class Otp extends StatefulWidget {
  const Otp({Key? key, required this.email, required this.verifCode})
      : super(key: key);

  final String email;
  final String verifCode;
  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: BuildAppbar('Forget Pwd'),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    Localfiles.illustration3,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Verification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Enter your OTP code number",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28),
                Container(
                  padding: EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(4, (index) {
                            return Expanded(
                              child: _textFieldOTP(
                                  controller: _otpControllers[index],
                                  first: index == 0,
                                  last: index == 3),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            EasyLoading.show(status: "Loading...");

                            String otpCode = '';
                            for (var controller in _otpControllers) {
                              otpCode += controller.text;
                            }
                            print(
                                'OTP Code: $otpCode'); // Affichage du code dans la console
                            if (isCodeValid(otpCode)) {
                              checkcode(widget.email, otpCode);
                            }
                          },
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Text(
                              'Verify',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  "Didn't you receive any code?",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                Text(
                  "Resend New Code",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkcode(String email, String verificationCode) async {
    var url = Uri.parse(Urls.user);

    try {
      final response = await http.post(url, headers: {
        "Accept": "application/json"
      }, body: {
        "email": encrypt(email),
        "code": encrypt(verificationCode),
        "action": encrypt("rentali_want_to_check_email_user_code_now")
      });
      // print(json.decode(response.body));
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }

      if (response.statusCode == 200) {
        if (data['message'] == 'Success activate your account') {
          EasyLoading.showSuccess("Success Activate");
          NavigationServices(context).gotoLoginScreen();
        }
        if (data['message'] == "Code is correct") {
          EasyLoading.showSuccess("Success code");
          NavigationServices(context).gotoResetPassword(email);
        }
      } else {
        if (data['status'] == 'error') {
          if (data['message'] == 'Incorrect code') {
            EasyLoading.showError('Incorrect Code');
          }
          if (data['message'] == "User request to delete account") {
            EasyLoading.showError('Compte Supprime');
          }
        } else {
          if (data['messsage'] == 'Success activate your account') {
            EasyLoading.showInfo('Compte Active avec Success');
            NavigationServices(context).gotohomeScreen();
          }
        }
      }
    } on SocketException {
      print('bbbbbbbbb');
      EasyLoading.dismiss();
    } catch (e) {
      print('tttttttttttt');
      print(e.toString());
      EasyLoading.dismiss();
    }
  }

  bool isCodeValid(String code) {
    // Vérification si le code est vide
    if (code.isEmpty) {
      EasyLoading.showError('Please fields All field',
          duration: Duration(seconds: 3));
      return false;
    }

    // Vérification si le code contient exactement 4 caractères
    if (code.length != 4) {
      EasyLoading.showError('Please fields All field',
          duration: Duration(seconds: 3));
      return false;
    }

    // Vérification si le code ne contient que des chiffres
    for (int i = 0; i < code.length; i++) {
      if (!RegExp(r'^[0-9]$').hasMatch(code[i])) {
        EasyLoading.showError('Invalid Format ',
            duration: Duration(seconds: 3));
        return false;
      }
    }

    // Si toutes les vérifications sont passées, le code est valide
    return true;
  }

  Widget _textFieldOTP(
      {required TextEditingController controller,
      required bool first,
      required bool last}) {
    return Container(
      height: 85,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ], // Only numbers can be entered
          controller: controller,
          autofocus: true,
          onChanged: (value) {
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.length == 0 && first == false) {
              FocusScope.of(context).previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          maxLength: 1,
          decoration: InputDecoration(
            counter: Offstage(),
          ),
        ),
      ),
    );
  }
}