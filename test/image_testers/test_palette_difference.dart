import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

import '../general.dart' as g;

Widget testPaletteDifference(imglib.Image image, {int rowsInPalette = 2}) {
  int imageWidth = image.width;
  int sampleSize = imageWidth ~/ g.samplesPerRow;
  int imageHeight = sampleSize * g.samplesPerColumn;

  List<Widget> metrics = [];

  for (int j = 0; j < imageHeight / rowsInPalette; j += sampleSize) {
    List<imglib.Pixel> samples = [];

    for (int i = 0; i < imageWidth * rowsInPalette; i += sampleSize) {
      int x = i % imageWidth;
      int y = j * rowsInPalette + i ~/ imageWidth * sampleSize;

      final pixel = image.getPixel(x + 50, y + 50);
      samples.add(pixel);
    }

    List<imglib.Pixel> leastAbsoluteErrorSamples = [];
    num leastAbsoluteError = 1000;

    for (int q = 0; q < rowsInPalette * g.samplesPerRow; q++) {
      for (int w = q + 1; w < rowsInPalette * g.samplesPerRow; w++) {
        num absoluteError = g.absoluteErrorOfRgb(samples[q], samples[w]);
        if (absoluteError < leastAbsoluteError) {
          leastAbsoluteError = absoluteError;
          leastAbsoluteErrorSamples = [samples[q], samples[w]];
        }
      }
    }

    metrics.addAll([
      Text('Palette #${j ~/ sampleSize}'),
      Text('Least absolute error: $leastAbsoluteError'),
      Text('Sample 1 (i, j): ${[
        leastAbsoluteErrorSamples[0].x ~/ sampleSize,
        leastAbsoluteErrorSamples[0].y ~/ sampleSize
      ]}'),
      Text('Sample 2 (i, j): ${[
        leastAbsoluteErrorSamples[1].x ~/ sampleSize,
        leastAbsoluteErrorSamples[1].y ~/ sampleSize
      ]}'),
      const Text('\n'),
    ]);

    for (final pixel in samples) {
      g.highlightPixel(pixel);
    }
  }

  return g.TestResultWrapper(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: metrics,
          ),
        ),
        Image.memory(imglib.encodeBmp(image)),
      ],
    ),
  );
}
