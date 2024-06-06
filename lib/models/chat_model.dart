class ChatModel {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;

  ChatModel(
      {required this.name,
      required this.message,
      required this.time,
      required this.avatarUrl});

  static List<ChatModel> dummyData = [
    ChatModel(
      name: "Cristian",
      message: "Hola, ¿cómo estás?",
      time: "15:30",
      avatarUrl:
          "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png",
    ),
    ChatModel(
      name: "Juan",
      message: "Hola, ¿qué tal?",
      time: "17:30",
      avatarUrl:
          "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png",
    ),
    ChatModel(
      name: "Pedro",
      message: "Hola, ¿qué haces?",
      time: "5:00",
      avatarUrl:
          "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png",
    ),
  ];
}
