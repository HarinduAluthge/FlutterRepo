import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget{
const LoginPage({super.key});

@override
State<LoginPage> createState()=> _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
String? errorMessage = '';
bool isLogin = true;

final TextEditingController _controllerEmail = TextEditingController();
final TextEditingController _controllerPassword = TextEditingController();

Future<void> signInWithEmailAndPassword() async {
  try{
    await Auth().sighInWithEmailAndPassword(
      email: _controllerEmail.text.trim(), 
      password: _controllerPassword.text.trim(),
    );
  } on FirebaseAuthException catch(e) {
    setState(() {
      errorMessage = e.message;
    });
  }
}

Future<void> createUserWithEmailAndPassword() async {
  try{
    await Auth().createUserWithEmailAndPassword(
      email: _controllerEmail.text.trim(), 
      password: _controllerPassword.text.trim(),
    );
  } on FirebaseAuthException catch(e){
    setState(() {
      errorMessage = e.message;
    });
  }
}

Widget _title(){
  return Text(
    isLogin ? 'Login' : 'Register',
    style: const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _entryField(
  String title,
  TextEditingController controller,
  {bool isPassword = false}
){
  return TextField(
    controller: controller,
    obscureText: isPassword,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: title,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
    ),
  );
}

Widget _errorMessage(){
  return Text(
    errorMessage == '' ? '' : 'Error: $errorMessage',
    style: const TextStyle(color: Colors.red, fontSize: 14),
  );
}

Widget _submitButton(){
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        isLogin ? 'Login' : 'Register',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget _loginOrRegisterButton(){
  return TextButton(
    onPressed: () {
      setState(() {
        isLogin = !isLogin;
      });
    },
    child: Text(
      isLogin ? 'Need an account? Register' : 'Have an account? Login',
      style: const TextStyle(color: Colors.white70),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0077B6),
            const Color(0xFF03045E),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 80),
              _title(),
              const SizedBox(height: 50),
              _entryField('Email', _controllerEmail),
              const SizedBox(height: 20),
              _entryField('Password', _controllerPassword, isPassword: true),
              const SizedBox(height: 20),
              _errorMessage(),
              const SizedBox(height: 24),
              _submitButton(),
              const SizedBox(height: 12),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    ),
  );
}

@override
void dispose() {
  _controllerEmail.dispose();
  _controllerPassword.dispose();
  super.dispose();
}
}

