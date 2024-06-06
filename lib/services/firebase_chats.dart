import "package:cloud_firestore/cloud_firestore.dart";
import "package:muni_san_roman/services/firebase_instances.dart";
import "package:muni_san_roman/services/firebase_users.dart";

class FirebaseChatServices {
  //get instance FirebaseFirestore
  final rooms = "rooms";

  Stream<List<Map<String, dynamic>>> getAllChats() {
    dynamic res = FirebaseInstancesServices.firestore
        .collection(rooms)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final room = doc.data();
        return room;
      }).toList();
    });

    return res;
  }

  Stream<List<Map<String, dynamic>>> getChatMessages(String roomId) {
    try {
      return FirebaseInstancesServices.firestore
          .collection('rooms') // Colección principal de salas
          .doc(roomId) // Documento específico identificado por roomId
          .snapshots() // Obtener un stream de cambios en el documento
          .map((docSnapshot) {
        // Acceder al campo 'messages' dentro del documento
        List<dynamic> messages = docSnapshot.data()!['messages'];
        // Convertir la lista de messages en una lista de mapas
        List<Map<String, dynamic>> messagesMap = messages.map((message) {
          return message as Map<String, dynamic>;
        }).toList();
        return messagesMap;
      });
    } catch (e) {
      return Stream.error(e);
    }
  }

  Future<void> sendMessage(
      String roomId, String message, String senderId) async {
    final senderRaw = await FirebaseUserServices.getUserById(senderId);
    final senderInfo = senderRaw.data();

    await FirebaseInstancesServices.firestore
        .collection(rooms)
        .doc(roomId)
        .update({
      "messages": FieldValue.arrayUnion([
        {
          "currentTime": DateTime.now(),
          "senderId": senderId,
          "contentMessage": message,
        }
      ]),
      "metadata": {
        "lastMessage": {
          "contentMessage": message,
          "typeMessage": "text",
          "sender":
              senderInfo, // TODO: aquí puse la información del usuario en duro osea como estaba en ese momento y es mejor cambiar a su id para consultar la información actual
        },
        "roomType": "one-to-one"
      },
      "settings": {}
    });
  }
}
