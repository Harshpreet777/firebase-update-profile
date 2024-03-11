import 'dart:io';

import 'package:firebase_demo3/core/models/user_model.dart';
import 'package:firebase_demo3/core/services/database_service.dart';
import 'package:firebase_demo3/core/viewmodels/base_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class UpdateProfileViewModel extends BaseModel {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String image = '';
  List gender = ["Male", "Female"];
  String select = '';
  String uid = "";

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  File? photo;
  final ImagePicker imagePicker = ImagePicker();
  Future imgFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      photo = File(pickedFile.path);
      updateUI();
    } else {
      debugPrint('No image selected.');
    }
  }

  Future imgFromCamera() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      photo = File(pickedFile.path);
      updateUI();
    } else {
      debugPrint('No image selected.');
    }
  }

  changeGender(String gender) {
    select=gender;
    updateUI();
  }

  Future uploadFile() async {
    if (photo == null) {
      return;
    }
    final fileName = basename(photo?.path ?? '');
    image = fileName;

    try {
      final ref = _firebaseStorage.ref().child(fileName);
      await ref.putFile(photo!);
      final url = await ref.getDownloadURL();
      debugPrint('url is $url');
    } catch (e) {
      debugPrint('error is $e');
    }
  }

  void updateProfile(String uid) async {
    String email = emailController.text;
    String name = nameController.text;
    String phoneNo = phoneNoController.text;
    String pass = passController.text;

    if (formKey.currentState?.validate() ?? false) {
      uploadFile();
      await DataBaseService(uid: uid).updateUserDetails(UserModel(
          uid: uid,
          email: email,
          name: name,
          phoneNo: phoneNo,
          image: image,
          pass: pass,
          gender: select));
    }
  }
}
