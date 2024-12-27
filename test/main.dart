import 'general.dart';
//import 'image_generators/generate_comparison_image.dart';
import 'image_generators/generate_gradient_image.dart';
import 'image_generators/generate_resolution_image.dart';
//import 'image_generators/generate_palettes_image.dart';
//import 'image_testers/test_color_correction_by_inv_lerp.dart';
import 'package:image/image.dart' as imglib;

void main() {
  //TestFuncs.drawTestImage(generateComparisonImage(), 'comparison_image');
  //TestFuncs.drawTestImage(generatePalettesImage(), 'palettes_image');

  // final res = rgbFromNonLinearSpace([
  //   200,
  //   200,
  //   0
  // ], [
  //   [0, 0, 0], //w
  //   [0, 0, 200], //b
  //   [0, 200, 0], //g
  //   [0, 200, 200], //c
  //   [200, 0, 0], //r
  //   [200, 0, 200], //m
  //   [200, 200, 0], //y
  //   [200, 200, 200], //k
  // ]);
  // print(res);

  //TestFuncs.drawImage(generateGradientImage, 'gradient_image');

  TestFuncs.drawImage(
      () => generateResolutionImage(
            height: 1440,
            width: 1080,
          ),
      'resolution_image');
}
