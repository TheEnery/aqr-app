import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

import '../general.dart';
import '../image_generators/generate_palettes_image.dart';
import '../test_result_wrapper.dart';

int _clamp(num value) => value.clamp(0, 255).toInt();

class MyColor {
  final double r, g, b;
  MyColor(this.r, this.g, this.b);

  MyColor operator -(MyColor other) =>
      MyColor(r - other.r, g - other.g, b - other.b);
  MyColor operator +(MyColor other) =>
      MyColor(r + other.r, g + other.g, b + other.b);
  MyColor operator *(double scalar) =>
      MyColor(r * scalar, g * scalar, b * scalar);

  double dot(MyColor other) => r * other.r + g * other.g + b * other.b;
}

MyColor trilinearInterpolation(
  double a,
  double b,
  double c,
  List<MyColor> boundaryColors,
) {
  // Використання трилінійної інтерполяції для знаходження кольору за коефіцієнтами a, b, c
  return boundaryColors[0] * ((1 - a) * (1 - b) * (1 - c)) +
      boundaryColors[1] * (a * (1 - b) * (1 - c)) +
      boundaryColors[2] * ((1 - a) * b * (1 - c)) +
      boundaryColors[3] * (a * b * (1 - c)) +
      boundaryColors[4] * ((1 - a) * (1 - b) * c) +
      boundaryColors[5] * (a * (1 - b) * c) +
      boundaryColors[6] * ((1 - a) * b * c) +
      boundaryColors[7] * (a * b * c);
}

List<double> inverseTrilinearInterpolation(
    MyColor measuredColor, List<MyColor> boundaryColors,
    {double tolerance = 1e-5, int maxIterations = 100}) {
  double a = 0.5, b = 0.5, c = 0.5; // Початкові наближення для коефіцієнтів
  for (int iter = 0; iter < maxIterations; iter++) {
    // Знаходимо поточне інтерпольоване значення
    MyColor interpolatedColor = trilinearInterpolation(a, b, c, boundaryColors);
    MyColor error = interpolatedColor - measuredColor;

    if (error.dot(error) < tolerance) {
      return [a, b, c];
    }

    // Обчислення частинних похідних
    MyColor dFdA =
        (trilinearInterpolation(a + tolerance, b, c, boundaryColors) -
                interpolatedColor) *
            (1 / tolerance);
    MyColor dFdB =
        (trilinearInterpolation(a, b + tolerance, c, boundaryColors) -
                interpolatedColor) *
            (1 / tolerance);
    MyColor dFdC =
        (trilinearInterpolation(a, b, c + tolerance, boundaryColors) -
                interpolatedColor) *
            (1 / tolerance);

    // Створюємо матрицю Якобі
    double jacobian00 = dFdA.r, jacobian01 = dFdB.r, jacobian02 = dFdC.r;
    double jacobian10 = dFdA.g, jacobian11 = dFdB.g, jacobian12 = dFdC.g;
    double jacobian20 = dFdA.b, jacobian21 = dFdB.b, jacobian22 = dFdC.b;

    // Обчислюємо зворотну матрицю Якобі
    double det =
        jacobian00 * (jacobian11 * jacobian22 - jacobian12 * jacobian21) -
            jacobian01 * (jacobian10 * jacobian22 - jacobian12 * jacobian20) +
            jacobian02 * (jacobian10 * jacobian21 - jacobian11 * jacobian20);

    if (det.abs() < tolerance) break;

    double invDet = 1.0 / det;
    double invJacobian00 =
        (jacobian11 * jacobian22 - jacobian12 * jacobian21) * invDet;
    double invJacobian01 =
        (jacobian02 * jacobian21 - jacobian01 * jacobian22) * invDet;
    double invJacobian02 =
        (jacobian01 * jacobian12 - jacobian02 * jacobian11) * invDet;

    double invJacobian10 =
        (jacobian12 * jacobian20 - jacobian10 * jacobian22) * invDet;
    double invJacobian11 =
        (jacobian00 * jacobian22 - jacobian02 * jacobian20) * invDet;
    double invJacobian12 =
        (jacobian02 * jacobian10 - jacobian00 * jacobian12) * invDet;

    double invJacobian20 =
        (jacobian10 * jacobian21 - jacobian11 * jacobian20) * invDet;
    double invJacobian21 =
        (jacobian01 * jacobian20 - jacobian00 * jacobian21) * invDet;
    double invJacobian22 =
        (jacobian00 * jacobian11 - jacobian01 * jacobian10) * invDet;

    // Оновлення наближень для `a`, `b`, `c`
    a -= invJacobian00 * error.r +
        invJacobian01 * error.g +
        invJacobian02 * error.b;
    b -= invJacobian10 * error.r +
        invJacobian11 * error.g +
        invJacobian12 * error.b;
    c -= invJacobian20 * error.r +
        invJacobian21 * error.g +
        invJacobian22 * error.b;

    // Перевірка, щоб значення `a`, `b`, `c` були в межах [0, 1]
    a = a.clamp(0.0, 1.0);
    b = b.clamp(0.0, 1.0);
    c = c.clamp(0.0, 1.0);
  }
  return [a, b, c];
}

RgbList rgbFromNonLinearSpace(RgbList value, List<RgbList> space) {
  final result = inverseTrilinearInterpolation(
    MyColor(value[0].toDouble(), value[1].toDouble(), value[2].toDouble()),
    space
        .map((c) => MyColor(c[0].toDouble(), c[1].toDouble(), c[2].toDouble()))
        .toList(),
  );
  return result.map((c) => _clamp(c * 255)).toList();
}

Widget testColorCorrectionByInvLerp(imglib.Image image) {
  int imageWidth = image.width;
  int sampleSize = imageWidth ~/ TestConsts.samplesPerRow;
  int imageHeight = sampleSize * TestConsts.samplesPerColumn;

  final samples = generatePalettesImage();

  final kwrgbycm = <RgbList>[];

  final metrics = <Widget>[];

  final pixels = [
    [0.45, 0.45],
    [0.45, 0.55],
    [0.55, 0.45],
    [0.55, 0.55],
  ]
      .map((xy) => [
            (xy[0] * sampleSize).toInt(),
            (xy[1] * sampleSize).toInt(),
          ])
      .toList();
  imglib.Color readSample(int i, int j, {bool highlight = true}) {
    List<num> avgColor = [0, 0, 0];
    for (final pixel in pixels) {
      final color = image.getPixel(
        i * sampleSize + pixel[0],
        j * sampleSize + pixel[1],
      );
      avgColor[0] += color.r;
      avgColor[1] += color.g;
      avgColor[2] += color.b;

      if (highlight) TestFuncs.highlightPixel(color);
    }
    final n = pixels.length;
    return imglib.ColorRgb8(
      (avgColor[0] / n).round(),
      (avgColor[1] / n).round(),
      (avgColor[2] / n).round(),
    );
  }

  for (int i = 0; i < TestConsts.samplesPerRow; i++) {
    //final color = image
    //    .getPixel(i * sampleSize + sampleSize ~/ 2, sampleSize ~/ 2)
    //    .clone();
    final color = readSample(i, 0, highlight: false);
    kwrgbycm.add([color.r.toInt(), color.g.toInt(), color.b.toInt()]);
  }

  final krgybmcw = [
    kwrgbycm[0],
    kwrgbycm[2],
    kwrgbycm[3],
    kwrgbycm[5],
    kwrgbycm[4],
    kwrgbycm[7],
    kwrgbycm[6],
    kwrgbycm[1],
  ];

  int mistakes = 0;
  num scanningErrorSum = 0;
  num predictionErrorSum = 0;

  for (int i = 0; i < TestConsts.samplesPerColumn; i++) {
    for (int j = 0; j < TestConsts.samplesPerRow; j++) {
      //final pixel = image.getPixel(
      //    j * sampleSize + sampleSize ~/ 2, i * sampleSize + sampleSize ~/ 2);
      final pixel = readSample(j, i);
      final scannedRgb = [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
      final calculatedRgb = rgbFromNonLinearSpace(scannedRgb, krgybmcw);
      final expectedRgb = samples[i * TestConsts.samplesPerRow + j];
      final scannedColor = pixel.clone();
      final calculatedColor = imglib.ColorRgb8(
          calculatedRgb[0], calculatedRgb[1], calculatedRgb[2]);
      final expectedColor =
          imglib.ColorRgb8(expectedRgb[0], expectedRgb[1], expectedRgb[2]);
      final scanningError =
          TestFuncs.absoluteErrorOfRgb(scannedColor, expectedColor);
      final predictionError = TestFuncs.absoluteErrorOfRgb(
        calculatedColor,
        expectedColor,
      );

      if (predictionError > scanningError) {
        mistakes++;
      }

      scanningErrorSum += scanningError;
      predictionErrorSum += predictionError;

      metrics.addAll([
        Text(
          'Sample (x, y): ($j, $i)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextWithColor('Scanned value: $scannedRgb', scannedRgb),
        TextWithColor('Actual value: $expectedRgb', expectedRgb),
        TextWithColor('Predicted value: $calculatedRgb', calculatedRgb),
        Text('Scanning error: $scanningError'),
        Text('Prediction error: $predictionError'),
      ]);

      //TestFuncs.highlightPixel(pixel);
    }
  }

  return TestResultWrapper(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [...metrics],
          ),
        ),
        Image.memory(imglib.encodeBmp(image)),
        Text('Prediction mistakes: $mistakes/${TestConsts.samplesCount} = '
            '${mistakes / TestConsts.samplesCount * 100}%'),
        Text('Average scanning error: '
            '${scanningErrorSum / TestConsts.samplesCount}'),
        Text('Average prediction error: '
            '${predictionErrorSum / TestConsts.samplesCount}'),
      ],
    ),
  );
}

class TextWithColor extends StatelessWidget {
  final String text;
  final RgbList color;

  const TextWithColor(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text),
        Container(
          width: 16.0,
          height: 16.0,
          color: Color.fromRGBO(color[0], color[1], color[2], 1.0),
        )
      ],
    );
  }
}
