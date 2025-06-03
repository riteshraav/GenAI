import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:arlex_getx/models/tokens.dart';
import 'package:arlex_getx/utils/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:arlex_getx/models/chat_model.dart';
import 'package:arlex_getx/models/chat_with_images_model.dart';
import 'package:arlex_getx/models/title_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:arlex_getx/models/image_generation_model.dart';
import 'package:arlex_getx/services/home_screen_service.dart';
import 'package:path/path.dart';
//import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../models/chat_with_doc_model.dart';

class HomeScreenController extends GetxController {
  late Gemini gemini = Gemini.instance;
  late Gemini newGemini = Gemini.instance;
  @override
  void onInit() async {
    super.onInit();
    drawerTitle.value = await homeScreenService.getChatTitlesForSideBar();
  }
  String ip = "http://192.168.43.43:8080";
  String curDocId = "";

  RxList<Content> chats = <Content>[].obs;
  RxList<Content> geminiChats = <Content>[].obs;
  List<ChatDataModel> chatDataList = [];
  List<ChatDataModel> geminiChatDetails = [];

  RxList<TitleModel> drawerTitle = <TitleModel>[].obs;

  RxList<ImageGenerationModel> generatedImages = <ImageGenerationModel>[].obs;
  RxList<ChatWithImagesModel> imageChats = <ChatWithImagesModel>[].obs;
  RxList<ChatWithDocModel> docChats = <ChatWithDocModel>[].obs;

  RxList<File> selectedImages = <File>[].obs;
  RxList<File> selectedDocuments = <File>[].obs;

  final TextEditingController inputChatController = TextEditingController();
  final TextEditingController inputImageGenController = TextEditingController();
  final TextEditingController inputChatWithImgController =
      TextEditingController();
  final TextEditingController inputDocController = TextEditingController();

  List<String> pagesString = [
    "ChatBot",
    "Generate AI Images",
    "Chat with Images",
    "Chat With Doc",
    "Chat with AI"
  ];
  RxString selectedScreenTitle = "ChatBot".obs;

  RxBool loading = false.obs;
  RxBool streamingData = false.obs;
  RxBool generatingImages = false.obs;
  RxBool streamingImageChat = false.obs;
  RxBool streamingDocChat = false.obs;

  final ScrollController chatScrollController = ScrollController();
  final ScrollController chatGeminiScrollController = ScrollController();
  final ScrollController imageGenerationScrollController = ScrollController();
  final ScrollController chatImagesScrollController = ScrollController();
  final ScrollController chatDocScrollController = ScrollController();

  final HomeScreenService homeScreenService;

  HomeScreenController({
    required this.homeScreenService,
  });

  scrollToBottomChat() {
    try {
      chatScrollController
          .jumpTo(chatScrollController.position.maxScrollExtent);
    } catch (e) {
      print(e);
    }
  }

  scrollToBottomImageGen() {
    try {
      imageGenerationScrollController
          .jumpTo(imageGenerationScrollController.position.maxScrollExtent);
    } catch (e) {
      print(e);
    }
  }

  scrollToBottomImageChat() {
    try {
      chatImagesScrollController
          .jumpTo(chatImagesScrollController.position.maxScrollExtent);
    } catch (e) {
      print(e);
    }
  }

  scrollToBottomDocChat() {
    try {
      chatDocScrollController
          .jumpTo(chatDocScrollController.position.maxScrollExtent);
    } catch (e) {
      print(e);
    }
  }

  void chatbotGetResponse() {
    if (inputChatController.text.trim() == "") {
      return;
    }
    streamingData.value = true;
    try {
      final searchedText = inputChatController.text.trim();
      chats.add(Content(role: 'user', parts: [Parts(text: searchedText)]));
      update();
      inputChatController.clear();
      gemini.streamChat(chats).listen((value) {
        loading.value = false;
        update();
        scrollToBottomChat();
        if (chats.isNotEmpty && chats.last.role == value.content?.role) {
          chats.last.parts!.last.text =
              '${chats.last.parts!.last.text}${value.output}';
        } else {
          chats.add(Content(role: 'model', parts: [Parts(text: value.output)]));
        }
      }, onDone: () {
        scrollToBottomChat();
        streamingData.value = false;
        final lastText = chats.isNotEmpty
            ? chats.last.parts
                ?.fold<String>('', (text, part) => text + part.text!)
            : '';

        chatDataList.add(ChatDataModel(
            query: searchedText, response: lastText ?? "Error occured"));
      });
    } catch (e) {
      streamingData.value = false;
      if (chats.last.role == 'user') {
        chats.removeLast();
      }
      Get.snackbar(
        'Error',
        'An error occurred please try again',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Future<void> imageGenGetResponseOld() async {
  //   final prompt = inputImageGenController.text.trim();
  //   inputImageGenController.clear();
  //   if (prompt == "") {
  //     return;
  //   }
  //   generatedImages.add(ImageGenerationModel(role: "user", prompt: prompt));
  //   scrollToBottomImageGen();
  //   update();
  //   generatingImages.value = true;
  //   try {
  //     generatedImages
  //         .add(ImageGenerationModel(role: "loading", imageByte: null, prompt: ''));
  //     update();
  //     final imageData = await homeScreenService.getImageService(prompt);
  //     final data = jsonDecode(imageData);
  //     generatedImages.removeLast();
  //     update();
  //     generatedImages.add(ImageGenerationModel(
  //         role: "model", imageByte: imageData, prompt: prompt));
  //     generatingImages.value = false;
  //     scrollToBottomImageGen();
  //     saveImageToGallery(data['imageB64']);
  //     update();
  //   } catch (e) {
  //     generatingImages.value = false;
  //     generatedImages.removeLast();
  //     update();
  //     Get.snackbar(
  //       'Error',
  //       'An error occurred please try again',
  //       snackPosition: SnackPosition.TOP,
  //       duration: const Duration(seconds: 3),
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }
  Future<void> imageGenGetResponse() async {
    final prompt = inputImageGenController.text.trim();
    inputImageGenController.clear();
    if (prompt == "") {
      return;
    }
    generatedImages.add(ImageGenerationModel(role: "user", prompt: prompt));
    scrollToBottomImageGen();
    update();
    generatingImages.value = true;
    try {
      generatedImages
          .add(ImageGenerationModel(role: "loading", imageByte: null, prompt: ''));
      update();
      final imageData = await generateImage(prompt);
      final data = imageData;
      generatedImages.removeLast();
      update();
      generatedImages.add(ImageGenerationModel(
          role: "model", imageByte: imageData, prompt: prompt));
      generatingImages.value = false;
      scrollToBottomImageGen();
      if(imageData != null) {
        saveImageToGallery(imageData);
      }
      update();
    } catch (e) {
      generatingImages.value = false;
      generatedImages.removeLast();
      update();
      Get.snackbar(
        'Error',
        'An error occurred please try again',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  void saveToFirebase() {
    streamingData.value = true;
    if (chats.isEmpty) return;
    try {
      chats.add(Content(role: 'user', parts: [
        Parts(
            text:
                "Write a single line title for this conversation. Give just a single line answer do not include any external line not even 'sure, here is ...'")
      ]));
      gemini.streamChat(chats).listen((value) {
        if (chats.isNotEmpty && chats.last.role == value.content?.role) {
          chats.last.parts!.last.text =
              '${chats.last.parts!.last.text}${value.output}';
        } else {
          chats.add(Content(role: 'model', parts: [Parts(text: value.output)]));
        }
      }, onDone: () async {
        String title = chats.last.parts!.last.text ?? DateTime.now().toString();
        streamingData.value = false;
        chats.removeLast();
        chats.removeLast();
        await homeScreenService.saveChatsToFirebase(
            chatDataList, title, curDocId);
        drawerTitle.value = await homeScreenService.getChatTitlesForSideBar();
      });
    } catch (e) {}
  }

  void saveImageToGallery(  Uint8List bytes) async {
    // Get external storage directory
    Directory? directory = await getExternalStorageDirectory();

    // Create a unique filename
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String path = '${directory!.path}/image_$timestamp.jpg';

    // Save image to file
    File(path).writeAsBytesSync(bytes);
    print('file saved');
    // Save image to the gallery
    //await ImageGallerySaver.saveFile(path);
  }

  Future<void> chatWithDocGetResponse() async {
    print("chat with doc called");
    final prompt = inputDocController.text.trim();
    inputDocController.text = "";
    streamingDocChat.value = true;
    if (prompt == "") {
      return;
    }
    try {
      docChats.add(ChatWithDocModel(prompt: prompt, role: "user"));
      update();
      scrollToBottomDocChat();
      final result = await askGeminiWithContext(prompt,selectedDocuments.first);

      docChats.add(ChatWithDocModel(
          prompt: '', role: "model", response: result));
      update();
      scrollToBottomDocChat();
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred please try again',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      streamingDocChat.value = false;
    }
    streamingDocChat.value = false;
  }
  Future<List<Uint8List>> processImages() async {
    List<Uint8List> imageBytes = await Future.wait(
      selectedImages.map((image) => image.readAsBytes()),
    );
    return imageBytes;
  }

  Future<void> chatWithImages() async {
    print("chat with image called");
    final prompt = inputChatWithImgController.text.trim();
    inputDocController.text = "";
    streamingDocChat.value = true;
    if (prompt == "") {
      print("prompt is emty");
      return;
    }
    try {
      imageChats.add(ChatWithImagesModel(images: [], prompt: prompt , response: '', role: 'user'));
      update();
      scrollToBottomDocChat();
      print("now result will be called");
      final result = await chatWithImageRequest(prompt,selectedImages.first);
    print("result calling done");
      imageChats.add(ChatWithImagesModel(images: await processImages(), prompt: '', response: result, role: 'model'
          ));
      print("result is $result");
      update();
      scrollToBottomDocChat();
    } catch (e) {
      print("here is exception for chat with image $e");
      Get.snackbar(
        'Error',
        'An error occurred please try again',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      streamingDocChat.value = false;
    }
    streamingDocChat.value = false;
  }

  Future<bool> uploadDocs() async {
    streamingDocChat.value = true;
    try {
      bool res = await homeScreenService.uploadDocsToServer(selectedDocuments);
      streamingDocChat.value = false;
      return res;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred please try again',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      streamingDocChat.value = false;
      return false;
    }
  }

  Future<void> getChatHistoryByDocId({required String docId}) async {
    try {
      chatDataList =
          await homeScreenService.getChatHistoryByDocId(docId: docId);

      chats.clear();
      chatDataList.forEach((chatItem) {
        chats.add(Content(role: 'user', parts: [Parts(text: chatItem.query)]));
        chats.add(
            Content(role: 'model', parts: [Parts(text: chatItem.response)]));
      });
      curDocId = docId;
    } catch (e) {
    } finally {
      update();
    }
  }
  // void geminiResponse() {
  //   if (inputChatController.text.trim() == "") {
  //     return;
  //   }
  //   streamingData.value = true;
  //   try {
  //     final searchedText = inputChatController.text.trim();
  //     geminiChats.add(Content(role: 'user', parts: [Parts(text: searchedText)]));
  //     ///Check what is happening here
  //     //TODO GEMINI VERSION OF THIS UPDATE LINE
  //     update();
  //     inputChatController.clear();
  //
  //   } catch (e) {
  //     streamingData.value = false;
  //     if (geminiChats.last.role == 'user') {
  //       geminiChats.removeLast();
  //     }
  //     Get.snackbar(
  //       'Error',
  //       'An error occurred please try again',
  //       snackPosition: SnackPosition.TOP,
  //       duration: const Duration(seconds: 3),
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }
  void geminiResponse() async {
    if (inputChatController.text.trim() == "") {
      return;
    }

    streamingData.value = true;
    final searchedText = inputChatController.text.trim();
    inputChatController.clear();
    String botResponse;
    try {
      // Add user message to chat
      geminiChats.add(Content(role: 'user', parts: [Parts(text: searchedText)]));
      update(); // Update UI

      // 🔁 Make API call to your Spring Boot backend
       botResponse = await askGeminiWithContext(searchedText,null);
      print("botresponse is $botResponse");
      // Add bot reply
      geminiChats.add(Content(role: 'model', parts: [Parts(text: botResponse)]));
      streamingData.value = false;
      update();
      scrollToBottomChat();

      // Save to chat history
      geminiChatDetails.add(ChatDataModel(
          query: searchedText, response: botResponse));
    } catch (e) {
      streamingData.value = false;

      // Remove user message if failed
      if (geminiChats.isNotEmpty && geminiChats.last.role == 'user') {
        geminiChats.removeLast();
      }
      print(e.toString());
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<String> askGemini(String prompt) async {
    print("ask gemini function called");
    String baseUrl = '$ip/api/ask-gemini';
    final uri = Uri.parse(baseUrl);
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(prompt),
    );
    print("response sent");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data["candidates"][0]["content"]['parts'][0]['text'];
      print("here is answer => $text");
      return text ; // depends on Spring Boot response key
    } else {
      throw Exception("Gemini request failed: ${response.body}");
    }
  }
  Future<String> askGeminiWithContext(String prompt,File? file) async {
    print("ask gemini with context function called");
    //  String baseUrl = '$ip/api/ask-gemini/context/1/1_8625322726';
    String baseUrlForPdf = '$ip/api/ask-gemini/context/1/1_8625322726';
    String baseUrlForImage = '$ip/api/ask-gemini/image/1/1_8625322726';
    var mimeType= '';
    var length = 0;
    var fileStream;
    if(file != null)
    {
      print("file is not null");
      mimeType = lookupMimeType(file.path)!;
      length = await file.length();
      fileStream = http.ByteStream(file.openRead());
      print('file length is $length');
    }
    else{
      print("file is null");
      final dummyData = utf8.encode('');
      final dummyStream = http.ByteStream.fromBytes(dummyData);
      mimeType = 'application/text';
      length = dummyData.length;
      fileStream =dummyStream;

    }
    final uri = Uri.parse( mimeType.substring(0,5) == 'image'?baseUrlForImage:baseUrlForPdf);
    final request =  http.MultipartRequest('POST',uri,
    );
    request.fields['prompt'] = prompt;
    if(file != null)
    {
      request.files.add(http.MultipartFile(
          'file',
          fileStream,
          length,
          filename: basename(file.path),
          contentType: MediaType.parse(mimeType)
      ));
    }
    else{
      request.files.add(http.MultipartFile(
          'file',
          fileStream,
          length,
          filename:'text.text',
          contentType: MediaType.parse(mimeType)
      ));
    }

    String? accessToken = await Tokens.getRefreshToken();
    if(accessToken == null)
    {
      CustomSnackbar.showError("error", "login again and try");
      return "";
    }
    request.headers.addAll({"Content-Type":"application/json","Authorization":"Bearer $accessToken"});
    final response = await request.send();
    print("response sent");
    if (response.statusCode == 200) {
      print("status code 200");
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      final text = data["candidates"][0]["content"]['parts'][0]['text'];
      print("here is answer => $text");
      return text ; // depends on Spring Boot response key
    } else {
      print("${response.statusCode}  here is statuscode ${response.stream.bytesToString()}");
      throw Exception("Gemini request failed: ${response.statusCode}");
    }
  }
  Future<String> chatWithImageRequest(String prompt,File? file) async {
    print("chat with image request called");
    String baseUrlForImage = '$ip/api/ask-gemini/image/1/1_8625322726';
    var mimeType= '';
    var length = 0;
    var fileStream;
    if(file == null){
      print("file is null");
    }
    if(file != null)
    {
      print("file is not null");
      mimeType = lookupMimeType(file.path)!;
      length = await file.length();
      fileStream = http.ByteStream(file.openRead());
      print('file length is $length');
    }
    final uri = Uri.parse(baseUrlForImage);
    final request =  http.MultipartRequest('POST',uri);
    request.fields['prompt'] = prompt;
    if(file != null)
    {
      request.files.add(http.MultipartFile(
          'file',
          fileStream,
          length,
          filename: basename(file.path),
          contentType: MediaType.parse(mimeType)
      ));
    }
    else{
      request.files.add(http.MultipartFile(
          'file',
          fileStream,
          length,
          filename: basename(""),
          contentType: MediaType.parse('application/pdf')
      ));
    }
    String? accessToken = await Tokens.getRefreshToken();
    if(accessToken == null)
    {
      CustomSnackbar.showError("error", "login again and try");
      return "";
    }
    request.headers.addAll({"Content-Type":"application/json","Authorization":"Bearer $accessToken"});

    final response = await request.send();
    print("response sent");
    if (response.statusCode == 200) {
      print("status code 200");
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      final text = data["candidates"][0]["content"]['parts'][0]['text'];
      print("here is answer => $text");
      return text ; // depends on Spring Boot response key
    } else {
      print("${response.statusCode}  here is statuscode ${response.stream.bytesToString()}");
      throw Exception("Gemini request failed: ${response.statusCode}");
    }
  }
  Future<Uint8List?> generateImage(String prompt)
  async{
    try {
      final url = Uri.parse('$ip/api/images/generate/$prompt');
      String? accessToken = await Tokens.getRefreshToken();
      if(accessToken == null)
      {
        CustomSnackbar.showError("error", "login again and try");
        throw Exception("accesstoken is null");
      }

      final response = await http.post(url,
      headers: {"Content-Type":"application/json","Authorization":"Bearer $accessToken"});

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  void clearAll() {
    chats.clear();
    chatDataList.clear();
    generatedImages.clear();
    imageChats.clear();
    docChats.clear();
    curDocId = "";
    update();
  }

  Future<bool> logout() async {
    try {
      await homeScreenService.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
