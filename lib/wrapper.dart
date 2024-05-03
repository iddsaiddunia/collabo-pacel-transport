import 'package:flutter/material.dart';
import 'package:pacel_trans_app/auth/home.dart';
import 'package:pacel_trans_app/nonAuth/registration.dart';

class Wrapper extends StatelessWidget {
  final bool isSignedIn;
  const Wrapper({super.key, required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return const HomePage();
    } else {
      return const RegistrationPage();
    }
  }
}