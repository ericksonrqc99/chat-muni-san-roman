import "package:cloud_firestore/cloud_firestore.dart";
import "package:muni_san_roman/models/room_model.dart";
import "package:muni_san_roman/models/user_model.dart";
import "package:muni_san_roman/services/firebase_instances.dart";
import "package:muni_san_roman/services/firebase_users.dart";
import "package:uuid/uuid.dart";

class FirebaseRoomServices {
  static Stream<List<String?>> getUserRoomIds(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        final data = snapshot.data();
        if (data == null || !data.containsKey('rooms')) {
          return <String>[];
        }
        return List<String>.from(data['rooms']);
      });
    } catch (e) {
      return Stream.error(e);
    }
  }

  static Stream<List<Map<String, dynamic>>> getRoomsByIds(
      List<String> roomIds) {
    try {
      return FirebaseFirestore.instance
          .collection('rooms')
          .where(FieldPath.documentId, whereIn: roomIds)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      return Stream.error(e);
    }
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getRoomById(
      String roomId) async {
    try {
      return await FirebaseFirestore.instance
          .collection("rooms")
          .doc(roomId)
          .get();
    } catch (e) {
      return Future.error(e);
    }
  }

  //get instance FirebaseFirestore
  Future<DocumentSnapshot<Map<String, dynamic>>?> getIdRoom(
      String idUser1, String idUser2) async {
    try {
      //obtener el usuario 1
      DocumentSnapshot<Map<String, dynamic>> user1doc =
          await FirebaseInstancesServices.firestore
              .collection("users")
              .doc(idUser1)
              .get();
      //obtener el usuario 2
      DocumentSnapshot<Map<String, dynamic>> user2doc =
          await FirebaseInstancesServices.firestore
              .collection("users")
              .doc(idUser2)
              .get();
      // obtenemos el uid del room que comparten o los que comparten
      if (user1doc.exists && user2doc.exists) {
        List<dynamic> roomsUser1 = user1doc.data()!["rooms"];
        List<dynamic> roomsUser2 = user2doc.data()!["rooms"];

        for (var room in roomsUser1) {
          if (roomsUser2.contains(room)) {
            // TODO: regresa solo la primera coincidencia, entonces solo sirve para chat de dos personas
            //obtenemos el room
            return await getRoomById(room);
          }
        }
        return null;
      } else {
        return throw Exception("User not found");
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<RoomModel> createRoom(String uidUser1, String uidUser2) async {
    try {
      // obtener la información del usuario 1
      DocumentSnapshot user1Raw =
          await FirebaseUserServices.getUserById(uidUser1);
      // instanciar un objeto UsuarioModel con la data de usuario 1
      UserModel user1Data = UserModel(
          photoUrl: user1Raw.get("photoUrl"),
          rooms: user1Raw.get("rooms"),
          email: user1Raw.get("email"),
          userName: user1Raw.get("userName"),
          uid: user1Raw.get("uid"));
      // obtener la información del usuario 2
      DocumentSnapshot user2Raw =
          await FirebaseUserServices.getUserById(uidUser2);
      // instanciar un objeto UsuarioModel con la data de usuario 2
      UserModel user2Data = UserModel(
          photoUrl: user2Raw.get("photoUrl"),
          rooms: user2Raw.get("rooms"),
          email: user2Raw.get("email"),
          userName: user2Raw.get("userName"),
          uid: user2Raw.get("uid"));
      // crear uuid
      String uuidRoom = const Uuid().v4();
      // crear una instancia de de un nuevo room con la información necesaria
      RoomModel room = RoomModel(
          roomId: uuidRoom,
          messages: [],
          metadata: {"roomType": "one-to-one"},
          settings: {},
          participants: [user1Data.toMap(), user2Data.toMap()]);
      //crear room
      await FirebaseInstancesServices.firestore
          .collection("rooms")
          .doc(uuidRoom)
          .set(room.toMap());
      //añadir uid del room creado al usuario 1
      await FirebaseInstancesServices.firestore
          .collection("users")
          .doc(uidUser1)
          .update({
        "rooms": FieldValue.arrayUnion([uuidRoom])
      });
      //añadir uid del room creado al usuario 2
      await FirebaseInstancesServices.firestore
          .collection("users")
          .doc(uidUser2)
          .update({
        "rooms": FieldValue.arrayUnion([uuidRoom])
      });
      return room;
    } catch (e) {
      return Future.error(e);
    }
  }
}
