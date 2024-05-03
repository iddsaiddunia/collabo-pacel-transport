import 'package:flutter/material.dart';
import 'package:pacel_trans_app/nonAuth/login.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: ListView(children: [
            Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height/7,
                color: Colors.transparent
            ),
            SizedBox(height: 20.0,),
            Text("Register",style: TextStyle(fontSize: 26),),
            Text("Please Register  to login.",style: TextStyle(fontSize: 16),),
            SizedBox(height: 20.0,),
            Container(
              width: double.infinity,
              height: 55.0,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.all(Radius.circular(30),),
              ),
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: "Username",
                    border: InputBorder.none
                ),
              ),
            ),
            SizedBox(height:20),
            Container(
              width: double.infinity,
              height: 55.0,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.all(Radius.circular(30),),
              ),
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: "Email",
                    border: InputBorder.none
                ),
              ),
            ),
            SizedBox(height:20),
            Container(
              width: double.infinity,
              height: 55.0,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.all(Radius.circular(30),),
              ),
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    hintText: "Phone",
                    border: InputBorder.none
                ),
              ),
            ),
            SizedBox(height:20),
            Container(
              width: double.infinity,
              height: 55.0,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.all(Radius.circular(30),),
              ),
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: "Password",
                    border: InputBorder.none
                ),
              ),
            ),
            SizedBox(height:20),
            Container(
              width: double.infinity,
              height: 55.0,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.all(Radius.circular(30),),
              ),
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: "verify Password",
                    border: InputBorder.none
                ),
              ),
            ),

            SizedBox(height:30),
            Container(
              width: double.infinity,
              height: 60.0,
              decoration: BoxDecoration(
                color: Colors.red[200],
                borderRadius: BorderRadius.all(Radius.circular(30),),
              ),
              child: Center(child: Text("Sign Up",style: TextStyle(fontSize: 17),)),
            ),
            SizedBox(height: 10.0,),
            Center(child: GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(

                    ),
                  ),
                );
              },
                child: Text("Already have an account?Sign In",style: TextStyle(fontSize: 16),)))


          ]),
        )
    );
  }
}