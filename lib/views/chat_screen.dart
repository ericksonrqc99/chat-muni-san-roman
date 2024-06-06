import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muni_san_roman/services/firebase_chats.dart';
import 'package:muni_san_roman/services/firebase_rooms.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  static String routeName = "chat-screen";

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();

  //controller of chat message
  final TextEditingController _textController = TextEditingController();
  // instance of Firebase Room Services
  final FirebaseRoomServices roomServices = FirebaseRoomServices();

  // list of messages chat Widget
  final List<ChatMessage> _listWidgetMessages = <ChatMessage>[];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //get the user you interact with obtained from the Firebase Firestore
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;

    final idRoom = arguments["room"]["roomId"];
    final otherUserName = arguments["room"]["participants"][0]["userName"];
    final otherUserEmail = arguments["room"]["participants"][0]["email"];

    // get the user that is logged in of Firebase Authentication
    final User? currentUser = FirebaseAuth.instance.currentUser;

    //init instance ChatServices
    final FirebaseChatServices chatServices = FirebaseChatServices();

    addMessageToView() {
      ChatMessage messageW = ChatMessage(message: _textController.text);
      setState(() {
        _listWidgetMessages.add(messageW);
        _textController.clear();
      });
    }

    saveMessageInDatabase(String? uidRoom, String message) {
      //save message in dabatabase
      chatServices.sendMessage(uidRoom!, message, currentUser!.uid);
    }

    // send message and add to list of messages
    void handleSubmitted() async {
      if (_textController.text.isEmpty) return;
      saveMessageInDatabase(idRoom, _textController.text);
      addMessageToView();
    }

    ListView buildListMenssages(snapshot, scrollController) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      return ListView.builder(
        controller: scrollController,
        key: const PageStorageKey<String>("chat-list"),
        padding: const EdgeInsets.all(8.0),
        itemCount: snapshot.length,
        itemBuilder: (_, index) {
          return Column(
            children: [
              Row(
                mainAxisAlignment:
                    snapshot[index]["senderId"] == currentUser!.uid
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: snapshot[index]["senderId"] == currentUser.uid
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot[index]["contentMessage"].toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10.0),
                        //transform timestamp to firestore to date time
                        Text(
                          DateFormat("dd-MM-yyyy HH:mm").format(
                              snapshot[index]["currentTime"].toDate()
                                  as DateTime),
                          style: TextStyle(color: Colors.grey[50], fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(otherUserEmail),
              const SizedBox(height: 1.0),
              Text(otherUserName,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          )),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder(
              stream: chatServices.getChatMessages(idRoom),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  return const Text("Error");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox.shrink(),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return const Text("Conexión cerrada");
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  final list = snapshot.data!.map((e) => e).toList();
                  return buildListMenssages(list, _scrollController);
                }
                return const Text("Resultado inesperado");
              },
            ),
          ),
          _buildBoxMessage(handleSubmitted),
        ],
      ),
    );
  }

  _buildBoxMessage(handleSubmitted) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _textController,
            onSubmitted: (String value) {
              handleSubmitted();
            },
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: () {
                  handleSubmitted();
                },
                child: const Icon(
                  Icons.send,
                  size: 30,
                ),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              fillColor: Colors.blue[50],
              filled: true,
              contentPadding: const EdgeInsets.all(15),
              hintText: "Escribe un mensaje...",
            ),
          ),
        ),
        const SizedBox(
          height: 7,
        )
      ],
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  const ChatMessage({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.only(top: 5.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
