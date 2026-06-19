import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropHelper {
  static Future<CroppedFile?> cropImage({
    required String sourcePath,
    required CropStyle cropStyle,
    required BuildContext context,
  }) async {
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Редактирование фото',
          toolbarColor: const Color(0xFF1E293B),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF6366F1),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: cropStyle == CropStyle.circle,
          cropStyle: cropStyle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
        IOSUiSettings(
          title: 'Редактирование фото',
          cropStyle: cropStyle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(
            width: 400,
            height: 400,
          ),
        ),
      ],
    );
  }
}
