
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

Future<bool> imageDownload({required Uint8List bytes}) async{
  try {
    // Saved with this method.
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(bytes),
        quality: 90,
        name: 'Shopdi ${DateTime.now()}');

    if (result == null || result == '') {
      return false;
    }

    return true;
  }catch (error) {
    if (kDebugMode) {
      print('error imageDownload: $error');
    }
    return false;
  }
}

