import 'dart:io';
import 'package:image/image.dart';

File getResizedImage(File file) {
print('======> file : ${file}');
  Image image = decodeImage(file.readAsBytesSync());

  //숫자를 높일수록 이미지 해상도 올라감
  Image thumbnail = copyResizeCropSquare(image, 1500);

  return File(file.path.substring(0, file.path.length-3)+'png')..writeAsBytesSync(encodeJpg(thumbnail, quality:50));
}

