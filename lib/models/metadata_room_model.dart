class MetadataRoomModel {
  final String? contentMessage;
  final String? typeMessage;
  final String? senderId;
  final String? roomType;

  MetadataRoomModel(
      {this.contentMessage = "",
      this.typeMessage = "",
      this.senderId = "",
      this.roomType = "one-to-one"});

  Map<String, dynamic> toMap() {
    return {
      "lastMessage": {
        contentMessage: contentMessage,
        typeMessage: typeMessage,
        senderId: senderId,
      },
      "roomType": roomType
    };
  }
}
