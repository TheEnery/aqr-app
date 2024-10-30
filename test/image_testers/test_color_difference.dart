import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

import '../general.dart' as g;

Widget testColorDifference(imglib.Image image) {
  int imageWidth = image.width;
  int sampleSize = imageWidth ~/ g.samplesPerRow;
  int imageHeight = sampleSize * g.samplesPerColumn;

  const pixelsCoords = [
    [45, 45],
    [55, 45],
    [45, 55],
    [55, 55],
  ];

  num meanAbsoluteError = 0;
  num maxAbsoluteError = 0;
  List<num> maxAbsoluteErrorSample = [];

  // i and j is x and y of the top left corner of the each sample
  for (int i = 0; i < imageWidth; i += sampleSize) {
    for (int j = 0; j < imageHeight; j += sampleSize) {
      for (int q = 0; q < pixelsCoords.length; q++) {
        for (int w = q + 1; w < pixelsCoords.length; w++) {
          num absoluteError = g.absoluteErrorOfRgb(
              image.getPixel(i + pixelsCoords[q][0], j + pixelsCoords[q][1]),
              image.getPixel(i + pixelsCoords[w][0], j + pixelsCoords[w][1]));

          meanAbsoluteError += absoluteError;
          if (absoluteError > maxAbsoluteError) {
            maxAbsoluteError = absoluteError;
            maxAbsoluteErrorSample = [i ~/ sampleSize, j ~/ sampleSize];
          }
        }
      }

      for (final shift in pixelsCoords) {
        g.highlightPixel(image.getPixel(i + shift[0], j + shift[1]));
      }
    }
  }

  meanAbsoluteError /= (pixelsCoords.length * (pixelsCoords.length - 1) / 2) *
      g.samplesPerRow *
      g.samplesPerColumn;

  return g.TestResultWrapper(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mean absolute error: $meanAbsoluteError'),
              Text('Max absolute error: $maxAbsoluteError'),
              Text('Max absolute error sample (i, j): $maxAbsoluteErrorSample'),
            ],
          ),
        ),
        Image.memory(imglib.encodeBmp(image)),
      ],
    ),
  );
}
