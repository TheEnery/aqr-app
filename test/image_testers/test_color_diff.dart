import 'package:image/image.dart';

import '../general.dart' as g;

num aePixel(Pixel p1, Pixel p2) {
  //print('${p1.r} ${p1.g} ${p1.b}   ${p2.r} ${p2.g} ${p2.b}');
  return (p1.r - p2.r).abs() + (p1.g - p2.g).abs() + (p1.b - p2.b).abs();
}

void testColorDiff(Image image) {
  int width = image.width;
  int size = (width / (g.width / g.size)).floor();
  int height = size * (g.height / g.size).floor();

  const testPixels = [
    [45, 45],
    [55, 45],
    [45, 55],
    [55, 55],
  ];
  num mae = 0;
  num aeMaxInImage = 0;
  List<num> aeMaxPixel = [];
  for (int i = 0; i < width; i += size) {
    for (int j = 0; j < height; j += size) {
      // i and j is x and y of the top left corner of the each sample
      num aeMax = 0;
      for (int o = 0; o < testPixels.length; o++) {
        for (int k = o + 1; k < testPixels.length; k++) {
          num ae = aePixel(
              image.getPixel(i + testPixels[o][0], j + testPixels[o][1]),
              image.getPixel(i + testPixels[k][0], j + testPixels[k][1]));
          //print(ae);
          mae += ae;
          if (ae > aeMax) {
            aeMax = ae;
          }
        }
      }
      if (aeMax > aeMaxInImage) {
        aeMaxInImage = aeMax;
        aeMaxPixel = [i / size, j / size];
      }
    }
  }
  mae /= (height / size) *
      (width / size) *
      (testPixels.length * (testPixels.length - 1) / 2);
  print('mae: ${mae}');
  print('max ae coords: ${aeMaxPixel}');
  print('max ae: ${aeMaxInImage}');
}
