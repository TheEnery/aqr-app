import 'general.dart';
import 'image_generators/generate_comparison_image.dart';
import 'image_generators/generate_palettes_image.dart';

void main() {
  TestFuncs.drawTestImage(generateComparisonImage(), 'comparison_image');
  TestFuncs.drawTestImage(generatePalettesImage(), 'palettes_image');
}
