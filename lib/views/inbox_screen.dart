import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "package:muni_san_roman/services/firebase_instances.dart";
import 'package:muni_san_roman/services/firebase_rooms.dart';
import 'package:muni_san_roman/views/chat_screen.dart';

class InboxScreen extends StatefulWidget {
  static const String routeName = "inbox-screen";
  const InboxScreen({super.key});
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  //instance of firebase
  final FirebaseFirestore firestore = FirebaseInstancesServices.firestore;
  //instance of fireauth
  final FirebaseAuth fireauth = FirebaseInstancesServices.fireauth;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String?>?>(
        stream: FirebaseRoomServices.getUserRoomIds(fireauth.currentUser!.uid),
        builder: (_, snapshotRoomsIds) {
          if (snapshotRoomsIds.hasError) {
            return Text(snapshotRoomsIds.toString());
          }
          if (snapshotRoomsIds.hasData == true &&
              snapshotRoomsIds.data!.isEmpty) {
            return ListView(children: [_buildNoChatsMessage()]);
          } else {
            if (snapshotRoomsIds.connectionState == ConnectionState.active) {
              // convertir la data llegada a una lista de Ids<String> de los rooms
              List<String> listOfRoomsId =
                  snapshotRoomsIds.data!.map((e) => e.toString()).toList();
              return _buildStreamBuilderRoomsByIds(listOfRoomsId);
            }
          }
          if (snapshotRoomsIds.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox.shrink(),
            );
          }
          return const Text("Inbox Screen");
        });
  }

  StreamBuilder<List<Map<String, dynamic>>> _buildStreamBuilderRoomsByIds(
      List<String> listOfRoomsId) {
    return StreamBuilder(
        stream: FirebaseRoomServices.getRoomsByIds(listOfRoomsId),
        builder: (context, roomSnapshot) {
          if (roomSnapshot.hasError) {
            return const Text("Upss parece que a ocurrido un error");
          }
          if (roomSnapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          if (roomSnapshot.connectionState == ConnectionState.active) {
            //convertir los datos llegados a una lista
            final listRooms = roomSnapshot.data!.toList();
            //remover los chats con idRoom pero sin interacción(mensajes)
            listRooms.removeWhere((room) => room["messages"].length == 0);
            return ListView(
                children: listRooms.isEmpty
                    ? [_buildNoChatsMessage()]
                    : listRooms
                        .map(
                          (room) => _buildChatListTile(room),
                        )
                        .toList());
          }
          return const SizedBox.shrink();
        });
  }

  Center _buildNoChatsMessage() {
    return const Center(
      child: Text("Sin Chats"),
    );
  }

  ListTile _buildChatListTile(Map<String, dynamic> room) {
    //obtener el otro usuario en la conversación cuando es un tipo de conversación one-to-one; osea un chat de dos

    room["participants"].removeWhere(
        (participant) => participant["uid"] == fireauth.currentUser!.uid);
    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, ChatScreen.routeName,
            arguments: {"room": room});
      },
      title: Text(room["participants"][0]["email"]),
      subtitle: Text(room["metadata"]["lastMessage"]["contentMessage"]),
      subtitleTextStyle: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontFamily: "Fredoka",
          fontWeight: FontWeight.w300),
    );
  }
}
