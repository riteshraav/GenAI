import 'package:arlex_getx/constants/colors.dart';
import 'package:arlex_getx/controller/auth_controller.dart';
import 'package:arlex_getx/helper/routes.dart';
import 'package:arlex_getx/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final controller = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homescreenBgColor,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Rectangle.png"),
                alignment: Alignment.topCenter,
                fit: BoxFit.fitWidth)),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40.h, left: 20.w),
              child: Image.asset(
                'assets/images/Asset.png', // Replace with your image path
                height: 80,
                width: 150,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 1,
                            color: Colors.grey.shade400,
                            spreadRadius: 1,
                            offset: const Offset(0, 3)),
                        const BoxShadow(
                            blurRadius: 0.5,
                            color: Colors.white24,
                            spreadRadius: 0.5,
                            offset: Offset(1, 1)),
                      ]),
                  margin: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // App Logo
                        Image.asset(
                          'assets/images/wisnolect.png', // Replace with your image path
                          height: 80,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Sign In',
                          style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor),
                        ),
                        const SizedBox(height: 20),
                        // Email TextField
                        TextField(
                          maxLines: 1,
                          controller: controller.emailController,
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                              labelText: 'Email',
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(15.r)),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15.h, horizontal: 15.w)),
                        ),
                        const SizedBox(height: 15),
                        // Password TextField
                        TextField(
                          obscureText: true,
                          controller: controller.passController,
                          maxLines: 1,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(15.r)),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15.h, horizontal: 15.w)),
                        ),
                        SizedBox(height: 5.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {}, // Add forgot password logic here
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Sign In Button
                        Obx(
                          () => InkWell(
                            onTap: () {
                              controller.loginUser().then((value) {
                                if (value) {
                                  Get.offAllNamed(RouteHelper.homeScreen);
                                }
                              });
                            },
                            child: Container(
                              width: double.maxFinite,
                              height: 40.h,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(15.r)),
                              child: Center(
                                child: controller.loading.value
                                    ? const Loader()
                                    : Text(
                                        "Sign In",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24.sp),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: 130.w,
                                child: const Divider(
                                  thickness: 1.5,
                                )),
                            const Text(
                              'or',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(
                                width: 130.w,
                                child: const Divider(
                                  thickness: 1.5,
                                )),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Sign in with Google Button
                        Container(
                          width: double.maxFinite,
                          height: 40.h,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(15.r)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.g_mobiledata_outlined,
                                size: 30.sp,
                              ),
                              Text(
                                "Sign in with Google",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(RouteHelper.signUpScreen);
                              }, // Add sign-up logic here
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
