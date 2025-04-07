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
  String currentPDFName = 'default';
  String fileSavePath = '';
  List<String> freeBookList = [];

  void updateUser(String email, String uid) {
    myEmail = email;
    myUid = uid;
  }

  void updateCurrentPDFName(String pdfName) {
    currentPDFName = pdfName;
  }

  void updateCurrentPage(int page) {
    currentPage = page;
  }

  void updateSaveFilePath(String path) {
    fileSavePath = path;
  }

  void updatePDFFiles(List<Map<String, String>> _pdfFiles) async {
    pdfFiles = _pdfFiles;
  }

  updateFreeBookList(List<String> _freeBookList) async {
    freeBookList = _freeBookList;
  }
}

final globalData = GlobalData();
