import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:muni_san_roman/components/text_form_field.dart';
import 'package:muni_san_roman/services/firebase_sign.dart';
import 'package:muni_san_roman/views/login_screen.dart';
import 'package:muni_san_roman/views/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  static String routeName = "register-screen";
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final double _heightSizedBox = 15;
  final double _borderRadius = 20;
  bool obscureText = true;

  //controlladores
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Form _buildBody() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildLogoMuni(),
              _buildSizedBoxY(),
              _buildTitleScreen(),
              _buildSizedBoxY(),
              MyTextFormField(
                controller: _userNameController,
                label: "Nombre de Usuario",
              ),
              _buildSizedBoxY(),
              MyTextFormField(
                  controller: _emailController,
                  label: "Correo Electronico",
                  keyboardType: TextInputType.emailAddress,
                  customValidation: _customValidationsEmail),
              _buildSizedBoxY(),
              MyTextFormField(
                controller: _passwordController,
                label: "Contraseña",
                obscureText: obscureText,
                isPasswordField: true,
                onPressSuffixPasswordField: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                customValidation: (value) {
                  if (value.length < 6) {
                    return "La contraseña debe tener al menos 6 caracteres";
                  }
                },
              ),
              _buildSizedBoxY(),
              MyTextFormField(
                controller: _repeatPasswordController,
                label: "Repetir Contraseña",
                obscureText: obscureText,
                isPasswordField: true,
                customValidation: (String value) {
                  if (_passwordController.text !=
                      _repeatPasswordController.text) {
                    return "Las contraseñas no coinciden";
                  }

                  if (value.length < 6) {
                    return "La contraseña debe tener al menos 6 caracteres";
                  }

                  return null;
                },
                onPressSuffixPasswordField: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
              ),
              _buildSizedBoxY(height: 30),
              _buildSignUpButton(),
              _buildSizedBoxY(height: 20),
              _buildMyDivider(),
              _buildSizedBoxY(height: 20),
              _buildSocialSign(),
              _buildSizedBoxY(height: 25),
              _buildNavigationToRegister(),
              _buildSizedBoxY()
            ],
          ),
        ),
      ),
    );
  }

  _customValidationsEmail(value) {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Correo inválido";
    }
    return null;
  }

  Center _buildTitleScreen() {
    return const Center(
      child: Text(
        "Registro",
        style: TextStyle(
            color: Color.fromARGB(255, 31, 104, 164),
            fontWeight: FontWeight.w600,
            fontSize: 30,
            fontFamily: "Fredoka"),
      ),
    );
  }

  Row _buildMyDivider() {
    return const Row(
      children: [
        Expanded(
            child: Divider(
          color: Colors.grey,
        )),
        SizedBox(
          width: 10,
        ),
        Text(
          "Inicio con redes sociales",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
            child: Divider(
          color: Colors.grey,
        )),
      ],
    );
  }

  Row _buildNavigationToRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("¿Ya tienes una cuenta? "),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
          },
          child: const Text(
            "Inicia sesión",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }

  Row _buildSocialSign() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          child: _buildSocialMediaButton(const FaIcon(
            FontAwesomeIcons.google,
            color: Colors.white,
          )),
        ),
      ],
    );
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      if (googleAuth == null) return false;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user == null) {
        return false;
      }
      if (userCredential.additionalUserInfo!.isNewUser == false) {
        return true;
      }
      String userName = userCredential.user!.displayName!;
      String userEmail = userCredential.user!.email!;
      saveUserInFireStore(userName, userEmail);
      return true;
    } on Exception {
      return false;
    }
  }

  Expanded _buildSocialMediaButton(Widget icon) {
    return Expanded(
      child: ElevatedButton(
          onPressed: () {
            signInWithGoogle().then((bool result) {
              if (result == true) {
                Navigator.pushReplacementNamed(context, MainScreen.routeName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("No se pudo iniciar sesión con Google")));
              }
            });
          },
          style: ButtonStyle(
            textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
            padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_borderRadius))),
            backgroundColor: WidgetStateProperty.all(
                const Color.fromARGB(255, 31, 104, 164)),
          ),
          child: icon),
    );
  }

  Expanded _buildSignUpButton() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.grey.shade400, spreadRadius: 1, blurRadius: 10)
        ]),
        child: ElevatedButton(
          onPressed: () async {
            final form = _formKey.currentState;
            if (!form!.validate()) return;
            try {
              await registerWithEmailAndPassword(_userNameController.text,
                  _emailController.text, _passwordController.text);
              if (!mounted) {
                return;
              }
              Navigator.pushReplacementNamed(context, MainScreen.routeName);
            } on FirebaseAuthException catch (e) {
              if (!mounted) {
                return;
              }
              if (e.code == "email-already-in-use") {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("El correo ya está registrado")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message.toString())));
              }
            }
          },
          style: ButtonStyle(
            textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
            padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_borderRadius))),
            backgroundColor: WidgetStateProperty.all(Colors.blue),
          ),
          child: const Text(
            "Registrarme",
            style: TextStyle(
              fontFamily: "Fredoka",
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _buildSizedBoxY({double height = -1}) {
    return SizedBox(
      height: height == -1 ? _heightSizedBox : height,
    );
  }

  SizedBox _buildLogoMuni() => SizedBox(
      height: 200,
      child: Image.asset("assets/images/logo-muni-san-roman-pequeno.png"));

  Future<UserCredential?> signInWithEmailAndPassword(user, password) async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: user.text, password: password.text);
  }

  validations(value, {customValidation}) {
    if (value.isEmpty) {
      return "Campo requerido";
    }
    if (customValidation != null) {
      return customValidation();
    }
    return null;
  }
}
