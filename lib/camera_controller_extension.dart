import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cqr/image_converter.dart';
import 'package:image/image.dart' as imglib;

extension CameraControllerExtension on CameraController {
  Future<imglib.Image> inMemoryImage() async {
    final completer = Completer<CameraImage>();
    await startImageStream(completer.complete);
    final image = await completer.future;
    await stopImageStream();
    return ImageConverter.convertCameraImage(image,
        rotationDegrees: description.sensorOrientation);
  }
}
