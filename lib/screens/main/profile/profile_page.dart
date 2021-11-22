import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentalz_flutter/screens/property/my_properties.dart';
import 'package:rentalz_flutter/services/auth.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (user != null) ...[
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(user.photoURL!),
        ),
        Container(
            padding: const EdgeInsets.all(8),
            child: Text("Hello, " + user.displayName!)),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border:
                          Border.all(width: 1, color: Colors.grey.shade300)),
                  child: IconButton(
                      onPressed: () {
                        FlutterRingtonePlayer.play(
                          android: AndroidSounds.notification,
                          ios: IosSounds.glass,
                          looping: false, // Android only - API >= 28
                          volume: 0.1, // Android only - API >= 28
                          asAlarm: false, // Android only - all APIs
                        );
                      },
                      icon: const Icon(Icons.notifications_active_outlined)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border:
                          Border.all(width: 1, color: Colors.grey.shade300)),
                  child: IconButton(
                      onPressed: () {
                        HapticFeedback.vibrate();
                      },
                      icon: const Icon(Icons.vibration_outlined)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border:
                          Border.all(width: 1, color: Colors.grey.shade300)),
                  child: IconButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                      },
                      icon: const Icon(Icons.edgesensor_low_outlined)),
                )
              ],
            ),
            OutlinedButton(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white)),
              child: const Text("Manage your properties"),
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return MyPropertyPage();
                    });
              },
            ),
            OutlinedButton(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue)),
              child: const Text("Log out"),
              onPressed: () {
                auth.signOut();
              },
            ),
          ],
        )
      ] else ...[
        OutlinedButton(
            onPressed: () {
              auth.googleSignIn();
            },
            child: const Text("Login with Google"))
      ],
    ]);
  }
}
