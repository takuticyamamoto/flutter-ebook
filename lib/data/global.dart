class GlobalData {
  static final GlobalData _instance = GlobalData._internal();
  factory GlobalData() {
    return _instance;
  }

  GlobalData._internal();
  List<Map<String, String>> pdfFiles = [];
  String myEmail = "default@gmail.com";
  String myUid = '1234567890';
  String myUserName = 'defaultUserName';
  String myName = 'defaultName';
  String profileURL =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqafzhnwwYzuOTjTlaYMeQ7hxQLy_Wq8dnQg&s";
  int currentPage = 1;
  void updateUser(String email, String uid, String username, String name) {
    myEmail = email;
    myUid = uid;
    myUserName = username;
    myName = name;
  }
}

// Create a single instance
final globalData = GlobalData();
