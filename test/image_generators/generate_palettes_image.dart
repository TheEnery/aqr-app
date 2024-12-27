import 'dart:math';

import 'package:image/image.dart' as imglib;

import '../general.dart';

List<RgbList> generatePalettesImage() {
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

  final hsv16samplesContrast = <List<int>>[];

  for (int i = 0; i < 16; i++) {
    hsv16samplesContrast
        .add(imglib.hsvToRgb(i / 16, 1, 0.65 + 0.15 * (i % 2 == 0 ? 1 : -1)));
  }

  final gray16samples = <List<int>>[];

  for (int i = 0; i < 16; i++) {
    gray16samples.add(imglib.hsvToRgb(0, 0, i / 16));
  }

  final contrastColors = _getMaxContrastColors(16);
  //[[0,0,0],[255,255,255],[75,125,135],[255,145,160],[]]

  return rgb8samples +
      rgb16samplesExtension +
      hsl16samples +
      hsv16samplesContrast +
      gray16samples +
      contrastColors;
}

double _rgbToLuminance(RgbList rgb) {
  double toLinear(int c) {
    double cLinear = c / 255.0;
    return (cLinear <= 0.04045)
        ? (cLinear / 12.92).toDouble()
        : (pow((cLinear + 0.055) / 1.055, 2.4)).toDouble();
  }

  double rLinear = toLinear(rgb[0]);
  double gLinear = toLinear(rgb[1]);
  double bLinear = toLinear(rgb[2]);

  return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
}

double _contrastRatio(RgbList color1, RgbList color2) {
  double l1 = _rgbToLuminance(color1);
  double l2 = _rgbToLuminance(color2);

  if (l1 < l2) {
    double temp = l1;
    l1 = l2;
    l2 = temp;
  }

  return (l1 + 0.05) / (l2 + 0.05);
}

List<RgbList> _getMaxContrastColors(int n) {
  final colors = <RgbList>[];

  for (int r = 0; r < 256; r += 5) {
    for (int g = 0; g < 256; g += 5) {
      for (int b = 0; b < 256; b += 5) {
        colors.add([r, g, b]);
      }
    }
  }

  final selectedColors = [colors[0]];

  for (int i = 1; i < n; i++) {
    double maxMinContrast = 0;
    List<int> bestColor = colors[0];

    for (var color in colors) {
      if (selectedColors.contains(color)) continue;

      double minContrast =
          selectedColors.map((c) => _contrastRatio(c, color)).reduce(min);

      if (minContrast > maxMinContrast) {
        maxMinContrast = minContrast;
        bestColor = color;
      }
    }

    selectedColors.add(bestColor);
  }

  return selectedColors;
}
