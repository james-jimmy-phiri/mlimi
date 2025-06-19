import 'dart:convert';

import 'package:mlimi/constants/url.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mlimi/pages/product_request/homepage.dart';

class AuthenticationController extends GetxController {
  final isLoading = false.obs;
  final token = ''.obs;

  final box = GetStorage();

  Future register({
    required String name,
    required String phone,
    required String location,
    required String pin,
    required String pinConfimation,
  }) async {
    try {
      isLoading.value = true;
      var data = {
        'name': name,
        'phone': phone,
        'location': location,
        'pin': pin,
        'pin_confimation': pinConfimation,
      };

      var response = await http.post(
        Uri.parse('${apiurl}register'),
        headers: {
          'Accept': 'application/json',
        },
        body: data,
      );

      // if (response.statusCode == 201) {
      isLoading.value = false;
      token.value = json.decode(response.body)['token'];
      box.write('token', token.value);
      Get.offAll(() => const Homepage());
      //} else {
      // isLoading.value = false;
      //Get.snackbar(
      //  'Error',
      //  json.decode(response.body)['message'],
      //  snackPosition: SnackPosition.TOP,
      //  backgroundColor: Colors.red,
      //  colorText: Colors.white,
      // );
      //  print(json.decode(response.body));
      //}
    } catch (e) {
      isLoading.value = false;

      print(e.toString());
    }
  }

  Future login({
    required String username,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      var data = {
        'username': username,
        'password': password,
      };

      var response = await http.post(
        Uri.parse('${apiurl}login'),
        headers: {
          'Accept': 'application/json',
        },
        body: data,
      );

      if (response.statusCode == 200) {
        isLoading.value = false;
        token.value = json.decode(response.body)['token'];
        box.write('token', token.value);
        Get.offAll(() => const Homepage());
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          json.decode(response.body)['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print(json.decode(response.body));
      }
    } catch (e) {
      isLoading.value = false;

      print(e.toString());
    }
  }
}
