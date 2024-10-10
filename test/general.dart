import 'package:image/image.dart' as imglib;

const width = 800;
const height = 1000;
const size = 100;

void generateComparisonSamples(List<List<int>> diffsamples, int count) {
  for (int i = 0; i < count; i++) {
    diffsamples.add(imglib.hsvToRgb(i / count, 1, 1));
  }
}

void fillTestRow(List<List<int>> rgbsamples, imglib.Image image, int row) {
  for (int i = 0; i < rgbsamples.length; i++) {
    final rgb = rgbsamples[i];
    final x = i * size % width;
    final y = ((i / (width / size)).floor() + row) * size;
    final colorRgb8 = imglib.ColorRgb8(rgb[0], rgb[1], rgb[2]);
    imglib.fillRect(image,
        x1: x, y1: y, x2: x + size, y2: y + size, color: colorRgb8);

    imglib.drawString(image, colorRgb8.toString(),
        font: imglib.arial14, x: x, y: y);
  }
}
