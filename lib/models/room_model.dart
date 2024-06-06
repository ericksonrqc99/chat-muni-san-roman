class RoomModel {
  List<dynamic> messages;
  String roomId;
  Map<String, dynamic> metadata;
  Map<String, dynamic> settings;
  List<dynamic> participants;
  RoomModel(
      {required this.messages,
      required this.roomId,
      required this.metadata,
      required this.settings,
      required this.participants});

  Map<String, dynamic> toMap() {
    return {
      "roomId": roomId,
      'messages': messages,
      'metadata': metadata,
      'settings': settings,
      'participants': participants
    };
  }
}
