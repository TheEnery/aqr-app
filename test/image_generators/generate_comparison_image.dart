import 'dart:io';
import '../general.dart';
import 'package:image/image.dart' as imglib;

void generateComparisonImage() {
  final image = imglib.Image(width: width, height: height);

  final diff1samples = <List<int>>[];
  generateComparisonSamples(diff1samples, 8);
  fillTestRow(diff1samples, image, 0);

  final diff2samples = <List<int>>[];
  generateComparisonSamples(diff2samples, 16);
  fillTestRow(diff2samples, image, 1);

  final diff3samples = <List<int>>[];
  generateComparisonSamples(diff3samples, 24);
  fillTestRow(diff3samples, image, 3);

  final diff4samples = <List<int>>[];
  generateComparisonSamples(diff4samples, 32);
  fillTestRow(diff4samples, image, 6);

  File('image_generators/output/comparison_image.png')
      .writeAsBytes(imglib.encodePng(image));
}
