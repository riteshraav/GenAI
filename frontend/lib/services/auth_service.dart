import 'dart:convert';
import 'package:arlex_getx/models/tokens.dart';
import 'package:arlex_getx/models/user.dart';
import 'package:arlex_getx/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:provider/provider.dart';

class AuthService extends GetxService {
  final ip =  "http://192.168.43.43:8080";
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    final url = Uri.parse("$ip/user/login");
    http.Response response;
    try {
    response = await http.post(url,
    headers: {"Content-Type":"application/json"},
    body: jsonEncode( {"email":email,"password":password})
    );

    if(response.statusCode == 200)
      {
        String? accessToken = response.headers["accesstoken"];
        String? refreshToken = response.headers["refreshtoken"];
        Tokens.saveTokens(accessToken!, refreshToken!);
        return "Successful";
      }
    else{
      print("in login service ${response.statusCode} ${response.body}");
      return response.body;
    }
    } catch (error) {
      print("error is in login service ${error}");
      return "Error";
    }
  }

  Future<String> signUp(CustomUser user) async {
    http.Response response;
    try {
      final uri = Uri.parse("$ip/user/signup");
      response = await http.post(uri, headers: {
        "Content-Type": "application/json",
      },
          body: jsonEncode(user.toJson())
      );

      if (response.statusCode == 200) {

        String? accessToken = response.headers["accesstoken"];
        String? refreshToken = response.headers["refreshtoken"];
        print("accessToken is  $accessToken");
        Tokens.saveTokens(accessToken!, refreshToken!);

        return "Successful";
      }
      else {
        print("${response.statusCode} ${response.body}");
        throw(response.body);
      }
    } catch (error) {
      rethrow;
    }
  }
  Future<void> saveUserDetails({
    required String name,
    required String uid,
  }) async {
    try {
      await FirebaseService.firestore
          .collection("Users")
          .doc(uid)
          .set({'name': name});
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkLoginStatus() async {
    String? refreshToken = await Tokens.getRefreshToken();
    http.Response response;
    if(refreshToken == null)
      {
        return false;
      }
    final url = Uri.parse("$ip/user/validate/refresh-token");
     response = await http.post(url,
        headers: {"Content-Type": "application/json",
          "Authorization": "Bearer $refreshToken"
        }
    );
    if(response.statusCode == 200)
      {
          String? accessToken = response.headers["accessToken"];
          String? refreshToken = response.headers["refreshToken"];
          Tokens.saveTokens(accessToken!, refreshToken!);
          return true;
      }
    else{
      print('here is responser of check login status  ${response.statusCode}  ${response.body}');
      return false;
    }
    
  }
}
