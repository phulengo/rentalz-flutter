import 'package:flutter/material.dart';
import 'package:rentalz_flutter/services/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthService auth = AuthService();

  @override
  void initState() {
    super.initState();
    if (auth.getUser != null) {
      Future.delayed(Duration.zero, () async {
        Navigator.pushReplacementNamed(context, "/home");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/logo/120x120.png",
            width: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade900),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.white)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Image.asset("assets/icons/google.png", width: 16),
                    const SizedBox(
                      width: 16,
                    ),
                    const Text(
                      "Continue with Google",
                    )
                  ]),
            ),
            onPressed: () async {
              var user = await auth.googleSignIn();
              if (user != null) {
                Navigator.pushReplacementNamed(context, "/home");
              }
            },
          ),
          TextButton(
              onPressed: () {
                // TODO: Sign In Anonymously
                Navigator.pushNamed(context, "/home");
              },
              child: const Text("Later"))
        ],
      )),
    );
  }
}
