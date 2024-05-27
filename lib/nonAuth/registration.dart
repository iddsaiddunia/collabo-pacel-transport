import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pacel_trans_app/nonAuth/login.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool isLoading = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController verifyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: ListView(children: [
        Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 7,
            color: Colors.transparent),
        SizedBox(
          height: 20.0,
        ),
        Text(
          "Register",
          style: TextStyle(fontSize: 26),
        ),
        Text(
          "Please Register  to login.",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 20.0,
        ),
        Container(
          width: double.infinity,
          height: 55.0,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: TextField(
            controller: usernameController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: "Username",
                border: InputBorder.none),
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 55.0,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                hintText: "Email",
                border: InputBorder.none),
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 55.0,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: TextField(
            controller: phoneController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone),
                hintText: "Phone",
                border: InputBorder.none),
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 55.0,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: TextField(
            controller: passwordController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: "Password",
                border: InputBorder.none),
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 55.0,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: TextField(
            controller: verifyController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: "verify Password",
                border: InputBorder.none),
          ),
        ),
        SizedBox(height: 30),
        GestureDetector(
          onTap: _signUp,
          child: Container(
            width: double.infinity,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.red[200],
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            child: Center(
              child: (!isLoading)
                  ? Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 17),
                    )
                  : CircularProgressIndicator(),
            ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Center(
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
                child: Text(
                  "Already have an account?Sign In",
                  style: TextStyle(fontSize: 16),
                )))
      ]),
    ));
  }

  _signUp() async {
    setState(() {
      isLoading = true;
    });
    if (emailController.text != "" ||
        passwordController.text != "" ||
        usernameController.text != "" ||
        phoneController.text != "") {
      if (passwordController.text == verifyController.text) {
        if (passwordController.text.length < 6) {
          setState(() {
            isLoading = false;
          });
          _showToast(context, "password  should be of legth 6 and above");
        } else {
          final user = await auth.createNewUser(
              emailController.text, passwordController.text);
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('clients')
                .doc(user.uid)
                .set({
              'username': usernameController.text.trim(),
              'phone': phoneController.text.trim(),
            });

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Alert!'),
                  content: Text('user was created successifully.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            _showToast(context, "user was not created");
          }
        }
      } else {
        _showToast(context, "Password don't match ");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      _showToast(context, "Please fill all fields");
    }
  }

  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
