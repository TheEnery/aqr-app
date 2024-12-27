import 'package:image/image.dart' as imglib;

const spacing = 100;

imglib.Image generateResolutionImage({
  required int height,
  required int width,
}) {
  final image = imglib.Image(height: height, width: width);

  imglib.fill(image, color: imglib.ColorRgb8(255, 255, 255));
  imglib.drawRect(image,
      x1: 0,
      y1: 0,
      x2: width - 1,
      y2: height - 1,
      color: imglib.ColorRgb8(255, 0, 0),
      thickness: 2);

  int x = spacing;
  int y = spacing;

  void drawLine(int thickness, imglib.Color color) {
    imglib.fillRect(
      image,
      x1: x,
      y1: y,
      x2: x + thickness,
      y2: y + spacing,
      color: color,
    );
    x += thickness;
  }

  void drawLinePair(int thickness) {
    drawLine(thickness, imglib.ColorRgb8(255, 255, 255));
    drawLine(thickness, imglib.ColorRgb8(0, 0, 0));
  }

  void drawInnerTrianglePair() {
    imglib.fillPolygon(image,
        vertices: [
          imglib.Point(0, y + spacing / 2),
          imglib.Point(spacing, y),
          imglib.Point(spacing, y + spacing),
        ],
        color: imglib.ColorRgb8(0, 0, 0));
    imglib.fillPolygon(image,
        vertices: [
          imglib.Point(width, y + spacing / 2),
          imglib.Point(width - spacing, y),
          imglib.Point(width - spacing, y + spacing),
        ],
        color: imglib.ColorRgb8(0, 0, 0));
  }

  void drawStripe(int thickness) {
    while (x < width - spacing) {
      drawLinePair(thickness);
    }

    drawInnerTrianglePair();
  }

  for (int i = 1; i <= 5; i++) {
    drawStripe(i);

    y += spacing;
    x = spacing;
  }

  final newHeight = height;
  final newWidth = width + 2 * spacing;
  final extendedImage = imglib.copyExpandCanvas(
    image,
    newHeight: newHeight,
    newWidth: newWidth,
    backgroundColor: imglib.ColorRgb8(255, 255, 255),
  );

  void drawOutterTrianglePair() {
    imglib.fillPolygon(extendedImage,
        vertices: [
          imglib.Point(spacing, y + spacing / 2),
          imglib.Point(0, y),
          imglib.Point(0, y + spacing),
        ],
        color: imglib.ColorRgb8(0, 0, 0));
    imglib.fillPolygon(extendedImage,
        vertices: [
          imglib.Point(newWidth - spacing - 1, y + spacing / 2),
          imglib.Point(newWidth - 1, y),
          imglib.Point(newWidth - 1, y + spacing),
        ],
        color: imglib.ColorRgb8(0, 0, 0));
  }

  y = spacing;

  for (int i = 1; i <= 5; i++) {
    drawOutterTrianglePair();
    y += spacing;
  }

  return extendedImage;
}
