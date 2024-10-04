import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cqr/image_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imglib;

extension InMemoryImageFromCameraController on CameraController {
  Future<imglib.Image> inMemoryImage() async {
    final completer = Completer<CameraImage>();
    await startImageStream(completer.complete);
    final image = await completer.future;
    await stopImageStream();

    debugPrint('');
    debugPrint('${image.width} ${image.height}');
    debugPrint('${image.format.group.name}');
    debugPrint('');

    return ImageUtils.convertCameraImage(image);
  }
}
