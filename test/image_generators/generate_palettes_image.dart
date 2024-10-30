import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as imglib;

import '../general.dart';

void generatePalettesImage() {
  final image = imglib.Image(width: imageWidth, height: imageHeight);

  final rgb8samples = [
    [0, 0, 0],
    [255, 255, 255],
    [255, 0, 0],
    [0, 255, 0],
    [0, 0, 255],
    [255, 255, 0],
    [0, 255, 255],
    [255, 0, 255],
  ];

  fillTestRow(rgb8samples, image, 0);

  final rgb16samplesExtension = [
    [85, 85, 85],
    [170, 170, 170],
    [127, 0, 0],
    [0, 127, 0],
    [0, 0, 127],
    [127, 127, 0],
    [0, 127, 127],
    [127, 0, 127],
  ];

  fillTestRow(rgb16samplesExtension, image, 1);

  final hsl16samples = [
    imglib.hslToRgb(0, 0, 0),
    imglib.hslToRgb(0, 0, 1),
  ];
  for (int i = 0; i < 360; i += 60) {
    hsl16samples.add(imglib.hslToRgb(i / 360, 1, 0.33));
  }
  hsl16samples.addAll([
    imglib.hslToRgb(0, 0, 0.33),
    imglib.hslToRgb(0, 0, 0.66),
  ]);
  for (int i = 0; i < 360; i += 60) {
    hsl16samples.add(imglib.hslToRgb(i / 360, 1, 0.66));
  }

  fillTestRow(hsl16samples, image, 2);

  final hsv16samplesContrast = <List<int>>[];

  for (int i = 0; i < 16; i++) {
    hsv16samplesContrast
        .add(imglib.hsvToRgb(i / 16, 1, 0.65 + 0.15 * (i % 2 == 0 ? 1 : -1)));
  }

  fillTestRow(hsv16samplesContrast, image, 4);

  final gray16samples = <List<int>>[];
  for (int i = 0; i < 16; i++) {
    gray16samples.add(imglib.hsvToRgb(0, 0, i / 16));
  }
  fillTestRow(gray16samples, image, 6);

  List<List<int>> colors = [];
  for (int r = 0; r < 256; r += 5) {
    for (int g = 0; g < 256; g += 5) {
      for (int b = 0; b < 256; b += 5) {
        colors.add([r, g, b]);
      }
    }
  }

  int n = 16;
  List<List<int>> contrastColors = getMaxContrastColors(colors, n);
  fillTestRow(contrastColors, image, 8);

  File('image_generators/output/palettes_image.png')
      .writeAsBytes(imglib.encodePng(image));
}

double rgbToLuminance(int r, int g, int b) {
  double toLinear(int c) {
    double cLinear = c / 255.0;
    return (cLinear <= 0.04045)
        ? (cLinear / 12.92).toDouble()
        : (pow((cLinear + 0.055) / 1.055, 2.4)).toDouble();
  }

  double rLinear = toLinear(r);
  double gLinear = toLinear(g);
  double bLinear = toLinear(b);

  // Обчислюємо світлосилу
  return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
}

double contrastRatio(List<int> color1, List<int> color2) {
  double l1 = rgbToLuminance(color1[0], color1[1], color1[2]);
  double l2 = rgbToLuminance(color2[0], color2[1], color2[2]);

  if (l1 < l2) {
    double temp = l1;
    l1 = l2;
    l2 = temp;
  }

  return (l1 + 0.05) / (l2 + 0.05);
}

List<List<int>> getMaxContrastColors(List<List<int>> colors, int n) {
  if (colors.length < n) return colors;

  List<List<int>> selectedColors = [colors[0]]; // Почнемо з першого кольору

  for (int i = 1; i < n; i++) {
    double maxMinContrast = 0;
    List<int> bestColor = colors[0];

    for (var color in colors) {
      if (selectedColors.contains(color)) continue;

      // Обчислення мінімального контрасту між поточним кольором і вибраними кольорами
      double minContrast =
          selectedColors.map((c) => contrastRatio(c, color)).reduce(min);

      // Перевірка, чи є цей колір найкращим кандидатом
      if (minContrast > maxMinContrast) {
        maxMinContrast = minContrast;
        bestColor = color;
      }
    }

    selectedColors.add(bestColor);
  }

  return selectedColors;
}
