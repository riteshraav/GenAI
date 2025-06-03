import 'package:arlex_getx/models/api_model.dart';
import 'package:arlex_getx/services/firebase_service.dart';
import 'package:arlex_getx/utils/custom_snackbar.dart';
import 'package:get/get.dart';

class ApiService extends GetxController {
  List<ApiModel> apiModel = [];
  @override
  Future<void> onInit() async {
    super.onInit();
    final model = await getApisFromFirebase();
    apiModel.add(model);
  }

  Future<ApiModel> getApisFromFirebase() async {
    try {
      final doc =
          await FirebaseService.firestore.collection("APIs").doc('api').get();
      final result = ApiModel.fromMap(doc.data()!);
      print("heres is result chatwithdocapi :  ${result.chatWithDocApi} "
          "\ngeminiapi ${result.geminiApi}"
          "\nimagegen api ${result.imageGenApi}"
          "\nuploaddocapi ${result.uploadDocApi}");
      return result;
    } catch (e) {
      CustomSnackbar.showError("Error!", "Something went wrong!");
      return ApiModel(
          geminiApi: "", imageGenApi: "", uploadDocApi: "", chatWithDocApi: "");
    }
  }
}
