import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController t = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  String? vid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PhoneNumber verification"),
      ),
      body: Column(
        children: [
          TextField(
            controller: t,
          ),
          ElevatedButton(
              onPressed: () async {
                print(t.text);
                await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: '+91 ${t.text}',
                    verificationCompleted:
                        (PhoneAuthCredential credential) async {
                      await auth.signInWithCredential(credential);
                    },
                    verificationFailed: (FirebaseAuthException e) {
                      if (e.code == 'invalid-phone-number') {
                        print('The provided phone number is not valid.');
                      }
                    },
                    codeSent: (String verificationId, int? resendToken) async {
                      vid = verificationId;
                    },
                    codeAutoRetrievalTimeout: (String verificationId) async {});
              },
              child: Text("Send OTP")),
          OtpTextField(
            numberOfFields: 6,
            borderColor: Color(0xFF512DA8),
            //set to true to show as box or false to show as dash
            showFieldAsBox: true,
            //runs when a code is typed in
            onCodeChanged: (String code) {
              //handle validation or checks here
            },
            //runs when every textfield is filled
            onSubmit: (String verificationCode) async {
              print(verificationCode);
              String smsCode = verificationCode;

              // Create a PhoneAuthCredential with the code
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: vid!, smsCode: smsCode);

              // Sign the user in (or link) with the credential
              await auth.signInWithCredential(credential).then((value) => (value) {
                        print(value);
                      });
            }, // end onSubmit
          ),
          ElevatedButton(onPressed: () {}, child: Text("Sign in")),
        ],
      ),
    );
  }
}
