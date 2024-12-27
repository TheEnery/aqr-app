import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

import '../image_generators/generate_resolution_image.dart';
import '../test_result_wrapper.dart';

bool isDark(imglib.Color color) => color.luminanceNormalized > 0.5;

Widget testResolution(imglib.Image image) {
  final y = image.height ~/ 2;

  int start = 2 * spacing;
  int end = image.width - start;
  int x = start;

  bool current = isDark(image.getPixel(x, y));
  while (current == isDark(image.getPixel(++x, y)) && x < end) {}

  if (x == end) {
    return TestResultWrapper(
        child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Not recongizable'),
        ),
        Image.memory(imglib.encodeBmp(image)),
      ],
    ));
  }

  num average = 0;
  int gaps = 0;

  while (x < end) {
    current = !current;

    int sameCount = 1;
    while (current == isDark(image.getPixel(++x, y))) {
      sameCount++;
    }

    if (x >= end) {
      break;
    }

    average += sameCount;
    gaps++;
  }

  imglib.drawLine(
    image,
    x1: start,
    x2: end,
    y1: y,
    y2: y,
    thickness: 4,
    color: imglib.ColorRgb8(255, 0, 0),
  );

  return TestResultWrapper(
      child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Average gap width: ${average / gaps}'),
      ),
      Image.memory(imglib.encodeBmp(image)),
    ],
  ));
}
