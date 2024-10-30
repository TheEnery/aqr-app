import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

const sampleSize = 100;
const samplesPerRow = 8;
const samplesPerColumn = 10;
const imageWidth = sampleSize * samplesPerRow;
const imageHeight = sampleSize * samplesPerColumn;

num absoluteErrorOfRgb(imglib.Pixel p1, imglib.Pixel p2) {
  return (p1.r - p2.r).abs() + (p1.g - p2.g).abs() + (p1.b - p2.b).abs();
}

void highlightPixel(imglib.Pixel p) {
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

class TestResultWrapper extends StatelessWidget {
  final Widget child;

  const TestResultWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 1.0,
      widthFactor: 1.0,
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }
}

void generateComparisonSamples(List<List<int>> diffsamples, int count) {
  for (int i = 0; i < count; i++) {
    diffsamples.add(imglib.hsvToRgb(i / count, 1, 1));
  }
}

void fillTestRow(List<List<int>> rgbsamples, imglib.Image image, int row) {
  for (int i = 0; i < rgbsamples.length; i++) {
    final rgb = rgbsamples[i];
    final x = i * sampleSize % imageWidth;
    final y = ((i / (imageWidth / sampleSize)).floor() + row) * sampleSize;
    final colorRgb8 = imglib.ColorRgb8(rgb[0], rgb[1], rgb[2]);
    imglib.fillRect(image,
        x1: x, y1: y, x2: x + sampleSize, y2: y + sampleSize, color: colorRgb8);

    imglib.drawString(image, colorRgb8.toString(),
        font: imglib.arial14, x: x, y: y);
  }
}
