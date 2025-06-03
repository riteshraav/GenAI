import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:arlex_getx/controller/home_screen_controller.dart';
import 'package:arlex_getx/models/image_generation_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/colors.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageGenerationItemWidget extends StatelessWidget {
  final ImageGenerationModel model;

  const ImageGenerationItemWidget({super.key, required this.model});
  Future<void> saveImageToDownloads(Uint8List imageBytes) async {
    // Request storage permission
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Storage permission not granted');
      return;
    }

    // Get the Downloads directory path
    Directory? downloadsDir = Directory('/storage/emulated/0/Download'); // This works for most Androids
    if (!await downloadsDir.exists()) {
      print("Downloads directory not found.");
      return;
    }

    // Create a unique filename
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String path = '${downloadsDir.path}/image_$timestamp.jpg';

    // Save the image
    File file = File(path);
    await file.writeAsBytes(imageBytes);
  }
  void saveImageToGallery() async {
    // Get external storage directory
    
    Directory? directory = await getExternalStorageDirectory();

    // Create a unique filename
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String path = '${directory!.path}/image_$timestamp.jpg';

    // Save image to file
    File(path).writeAsBytesSync(model.imageByte!);
    print('file saved at $path');
    // Save image to the gallery
    //await ImageGallerySaver.saveFile(path);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (model.role == "user")
          Padding(
            padding: EdgeInsets.only(bottom: 5.h, top: 5.h),
            child: Row(
              children: [
                Container(
                  width: 35.w,
                  height: 35.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: AppColors.blackColor),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(10.h),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: const Color(0xFF7176ED)),
                        child: Text(model.prompt!,
                            style: TextStyle(
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2))),
              ],
            ),
          )
        else if (model.role == "loading")
          Padding(
            padding: EdgeInsets.only(
                top: 10.h, bottom: 10.h, left: 20.w, right: 10.w),
            child: Container(
              width: 320.w,
              height: 320.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: AppColors.homescreenBgColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 280.w,
                      height: 280.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          color: AppColors.whiteColor),
                      child: Center(
                        child: Lottie.asset('assets/lottie/ai.json',
                            width: 200.w, height: 200.h),
                      )),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, top: 5.h, right: 20.w),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/Star.svg',
                          height: 20.h,
                          width: 20.w,
                          color: AppColors.secondaryColor,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          "Generating an Image..!",
                          style: TextStyle(color: Colors.black),
                        ),
                        Spacer(),
                        Icon(
                          Icons.download,
                          size: 20.sp,
                          color: AppColors.secondaryColor,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.only(
                top: 10.h, bottom: 10.h, left: 20.w, right: 10.w),
            child: Container(
              width: 320.w,
              height: 320.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: AppColors.homescreenBgColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 280.w,
                    height: 280.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: AppColors.whiteColor),
                    child:(model.imageByte != null)? Image.memory(
                      model.imageByte as Uint8List,
                      fit: BoxFit.cover,
                      height: 280,
                      width: 280, // Adjust the height as needed
                    ):const Text("Error in generating image"),
                  ),
                  if(model.imageByte != null)
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, top: 5.h, right: 20.w),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/Star.svg',
                          height: 20.h,
                          width: 20.w,
                          color: AppColors.secondaryColor,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          "Here you go!",
                          style: TextStyle(color: Colors.black),
                        ),
                        Spacer(),
                       InkWell(
                         onTap: () {
                           print("button pressed");
                           saveImageToDownloads(model.imageByte!);
                         },
                         child: Icon(
                              Icons.download,
                              color: AppColors.secondaryColor,
                            ),
                       ),



                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}
