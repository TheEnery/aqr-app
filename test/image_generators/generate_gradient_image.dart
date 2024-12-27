import 'dart:math';

import 'package:image/image.dart' as imglib;

import '../general.dart';

void generateGradientImage(imglib.Image image) {
  for (int step = 1; step < pow(2, 8); step *= 2) {
    _drawGradient(image, TestConsts.sampleSize ~/ 5, step);
  }
}

int _row = 0;

void _drawGradient(imglib.Image image, int width, int step) {
  if (width == 0) return;

  final color = imglib.ColorRgb8(0, 0, 0);

  for (int i = 0; i < TestConsts.imageWidth; i += width) {
    imglib.fillRect(image,
        x1: i,
        y1: _row,
        x2: i + width,
        y2: _row + TestConsts.sampleSize,
        color: color);

    color.r += step;
    color.g += step;
    color.b += step;
  }

  _row += TestConsts.sampleSize;
}
