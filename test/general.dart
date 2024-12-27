import 'dart:io';

import 'package:image/image.dart' as imglib;

typedef RgbList = List<int>;

class TestConsts {
  static const sampleSize = 100;
  static const samplesPerRow = 8;
  static const samplesPerColumn = 10;
  static const samplesCount = samplesPerRow * samplesPerColumn;
  static const imageWidth = sampleSize * samplesPerRow;
  static const imageHeight = sampleSize * samplesPerColumn;
}

class TestFuncs {
  static num absoluteErrorOfRgb(imglib.Color p1, imglib.Color p2) {
    return (p1.r - p2.r).abs() + (p1.g - p2.g).abs() + (p1.b - p2.b).abs();
  }

  static void drawTestImage(List<RgbList> samples, String filename) {
    final image = imglib.Image(
        width: TestConsts.imageWidth, height: TestConsts.imageHeight);

    for (int i = 0; i < samples.length; i++) {
      final rgb = samples[i];
      final x = (i % TestConsts.samplesPerRow) * TestConsts.sampleSize;
      final y = (i ~/ TestConsts.samplesPerRow) * TestConsts.sampleSize;
      final colorRgb8 = imglib.ColorRgb8(rgb[0], rgb[1], rgb[2]);
      imglib.fillRect(image,
          x1: x,
          y1: y,
          x2: x + TestConsts.sampleSize,
          y2: y + TestConsts.sampleSize,
          color: colorRgb8);

      imglib.drawString(image, colorRgb8.toString(),
          font: imglib.arial14, x: x, y: y);
    }

    File('image_generators/output/$filename.png')
        .writeAsBytes(imglib.encodePng(image));
  }

  static void drawImage(imglib.Image Function() build, String filename) {
    final image = build();

    File('image_generators/output/$filename.png')
        .writeAsBytes(imglib.encodePng(image));
  }

  static void drawDefaultImage(
      void Function(imglib.Image image) build, String filename) {
    final image = imglib.Image(
        width: TestConsts.imageWidth, height: TestConsts.imageHeight);

    build(image);

    File('image_generators/output/$filename.png')
        .writeAsBytes(imglib.encodePng(image));
  }

  static void highlightPixel(imglib.Pixel p) {
    final image = p.image;
    final color = p.luminanceNormalized > 0.5
        ? imglib.ColorRgb8(0, 0, 0)
        : imglib.ColorRgb8(255, 255, 255);

    image.setPixel(p.x, p.y, color);

    image.setPixel(p.x + 1, p.y, color);
    image.setPixel(p.x, p.y + 1, color);
    image.setPixel(p.x - 1, p.y, color);
    image.setPixel(p.x, p.y - 1, color);
  }
}
