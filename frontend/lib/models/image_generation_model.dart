// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:typed_data';

class ImageGenerationModel {
  final Uint8List? imageByte;
  final String? prompt;
  final String role;

  ImageGenerationModel({this.imageByte, this.prompt, required this.role});

}
