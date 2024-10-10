import 'package:image/image.dart';

import '../general.dart' as g;
import 'test_color_diff.dart';

void testPaletteDiff(Image image) {
  int width = image.width;
  int size = (width / (g.width / g.size)).floor();
  int height = size * (g.height / g.size).floor();

  for (int j = 0; j < height / 2; j += size) {
    List<Pixel> ps = [];

    for (int i = 0; i < width * 2; i += size) {
      // my palettes have 16 colors in 2 rows each have 8 sampes
      int x = i % width;
      int y = j * 2 + (i / width).floor() * size;
      ps.add(image.getPixel(x + 50, y + 50));
    }

    Pixel lp1 = ps[0], lp2 = ps[1];
    num leastAe = 1000;

    for (int o = 0; o < 16; o++) {
      for (int k = o + 1; k < 16; k++) {
        num ae = aePixel(ps[o], ps[k]);
        if (ae < leastAe) {
          leastAe = ae;
          lp1 = ps[o];
          lp2 = ps[k];
        }
      }
    }

    print('Leas ae: $leastAe');
    print('p1: $lp1 ${(lp1.x / size).floor()} ${(lp1.y / size).floor()}');
    print('p2: $lp2 ${(lp2.x / size).floor()} ${(lp2.y / size).floor()}');
  }
}
