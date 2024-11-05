import '../general.dart';
import 'package:image/image.dart' as imglib;

List<RgbList> generateComparisonImage() {
  final diff1samples = _generateComparisonSamples(8);

  final diff2samples = _generateComparisonSamples(16);

  final diff3samples = _generateComparisonSamples(24);

  final diff4samples = _generateComparisonSamples(32);

  return diff1samples + diff2samples + diff3samples + diff4samples;
}

List<RgbList> _generateComparisonSamples(int count) {
  final samples = <RgbList>[];
  for (int i = 0; i < count; i++) {
    samples.add(imglib.hsvToRgb(i / count, 1, 1));
  }
  return samples;
}
