import 'dart:developer';
import 'dart:io';

import 'package:commons/helpers/image_picker_helper/image_picker_helper.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelperImplementation implements ImagePickerHelper {
  @override
  Future<FileImage?> pickImage() async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        return FileImage(File(xFile.path));
      }
      return null;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
