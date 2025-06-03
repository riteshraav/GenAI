import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Tokens{
  static final storage = FlutterSecureStorage();
 static Future<void> saveTokens(String accessToken, String refreshToken)
 async {
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
  }
  static Future<String?> getAccessToken()async{
    return  await storage.read(key: 'accessToken');
  }
  static Future<String?> getRefreshToken()async{
    return  await storage.read(key: 'refreshToken');
  }
  static Future<void> deleteTokens()async{
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');

  }
}