import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:muni_san_roman/models/room_model.dart';
import 'package:muni_san_roman/models/user_model.dart';
import 'package:muni_san_roman/services/firebase_instances.dart';
import 'package:muni_san_roman/services/firebase_users.dart';
import 'package:muni_san_roman/views/chat_screen.dart';
import 'package:muni_san_roman/views/configuration_screen.dart';
import 'package:muni_san_roman/views/inbox_screen.dart';

import '../services/firebase_rooms.dart';

class MainScreen extends StatefulWidget {
  static String routeName = "main-screen";

  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndexBottom = 0;
  bool _isSearching = false;
  final focus = FocusNode();
  final _screens = [
    const InboxScreen(),
    const ConfigurationScreen(),
  ];

  late FocusNode _searchFocusNode;
  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearching = _searchFocusNode.hasFocus;
    });
  }

  RoomModel deleteCurrentUser(RoomModel room) {
    final fireauth = FirebaseInstancesServices.fireauth;
    final newRoom = room;
    newRoom.toMap()["participants"].removeWhere(
        (participant) => participant["uid"] == fireauth.currentUser!.uid);

    return newRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 31, 104, 164),
        actions: [
          Visibility(
              visible: !_isSearching,
              child: IconButton(
                  icon: _isSearching
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                  onPressed: () {
                    _isSearching = !_isSearching;
                    setState(() {});
                  }))
        ],
        title: _isSearching
            ? Expanded(
                child: DropDownSearchField(
                textFieldConfiguration: TextFieldConfiguration(
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12),
                        prefixIcon: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 25,
                          ),
                          onPressed: () {
                            _isSearching = false;
                            setState(() {});
                          },
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Buscar",
                        hintStyle: const TextStyle(color: Colors.grey))),
                suggestionsCallback: (pattern) async {
                  if (pattern.isEmpty) {
                    return [];
                  }
                  return await FirebaseUserServices.searchByEmailAddress(
                      pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['email']),
                  );
                },
                onSuggestionSelected: (suggestion) async {
                  UserModel otherUser = UserModel(
                    rooms: suggestion["rooms"],
                    email: suggestion['email'],
                    userName: suggestion['userName'],
                    photoUrl: suggestion['photoUrl'],
                    uid: suggestion['uid'],
                    status: suggestion['status'],
                  );
                  //verifyExistingRoom
                  final currentUser =
                      FirebaseInstancesServices.fireauth.currentUser!;
                  FirebaseRoomServices()
                      .getIdRoom(currentUser.uid, otherUser.uid)
                      .then((room) {
                    if (room == null) {
                      FirebaseRoomServices()
                          .createRoom(
                              FirebaseInstancesServices
                                  .fireauth.currentUser!.uid,
                              otherUser.uid)
                          .then((RoomModel newRoom) {
                        // eliminar el currentusecr para poder nombrar el chat con el nombre del otro usuario
                        final roomWithoutCurrentUser =
                            deleteCurrentUser(newRoom).toMap();

                        Navigator.pushNamed(context, ChatScreen.routeName,
                            arguments: {"room": roomWithoutCurrentUser});
                      });
                    } else {
                      try {
                        RoomModel existingRoom = RoomModel(
                          messages: room.get("messages"),
                          roomId: room.get("roomId"),
                          metadata: room.get("metadata"),
                          settings: room.get("settings"),
                          participants: room.get("participants"),
                        );
                        final roomWithoutCurrentUser =
                            deleteCurrentUser(existingRoom).toMap();
                        Navigator.pushNamed(context, ChatScreen.routeName,
                            arguments: {
                              "room": roomWithoutCurrentUser,
                            });
                      } catch (e) {
                        print("Error:main_screen.dart:161 $e");
                      }
                    }
                  });

                  // si no existe creo un room uid
                },
                displayAllSuggestionWhenTap: true,
                debounceDuration: Durations.long1,
                loadingBuilder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  elevation: 4,
                  constraints: const BoxConstraints(maxHeight: 200),
                  hasScrollbar: true,
                ),
                hideOnLoading: true,
                noItemsFoundBuilder: (context) {
                  return const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "No se encontraron resultados",
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                },
              ))
            : const Text(
                "Muni San Román",
                style: TextStyle(color: Colors.white),
              ),
      ),
      body: _screens[_selectedIndexBottom],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndexBottom,
        onTap: (index) => {_selectedIndexBottom = index, setState(() {})},
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.message),
            icon: Icon(Icons.message_outlined),
            label: "Chats",
            backgroundColor: Color.fromARGB(255, 31, 104, 164),
          ),
          BottomNavigationBarItem(
              activeIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: "Configuraciones",
              backgroundColor: Color.fromARGB(255, 31, 104, 164))
        ],
      ),
    );
  }
}
