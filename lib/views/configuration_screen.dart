import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muni_san_roman/services/firebase_instances.dart';
import 'package:muni_san_roman/services/firebase_sign.dart';
import 'package:muni_san_roman/services/firebase_users.dart';
import 'package:muni_san_roman/views/login_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  //instanciar fireauth
  FirebaseAuth fireauth = FirebaseInstancesServices.fireauth;
  //obtener usuario actual

  getUserInformation(String userId) async {
    return await FirebaseUserServices.getUserById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          FutureBuilder(
              future:
                  FirebaseUserServices.getUserById(fireauth.currentUser!.uid),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [
                      ListTile(
                        title: const Text("Nombre de Usuario:"),
                        subtitle: Text(snapshot.data!["userName"]),
                      ),
                      ListTile(
                        title: const Text("Correo:"),
                        subtitle: Text(snapshot.data!["email"]),
                      )
                    ],
                  );
                }
                return const CircularProgressIndicator();
              }),
          const Expanded(
            child: SizedBox.shrink(),
          ),
          TextButton(
              onPressed: () {
                logout();
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
              child: const Text(
                "Cerrar Sesión",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              )),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
