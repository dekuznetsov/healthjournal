import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // 1. Fill background with a nice gradient-like teal color
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      // Simple vertical gradient from teal to dark teal
      final r = (0 + (y / size * 20)).toInt();
      final g = (150 + (y / size * 40)).toInt();
      final b = (136 + (y / size * 40)).toInt();
      image.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }

  // 2. Draw a white rounded square (inset)
  const inset = 80;
  final white = img.ColorRgb8(255, 255, 255);
  final teal = img.ColorRgb8(0, 150, 136);

  // 3. Draw a stylized heart or pulse line
  // Let's draw a "Pulse" line with a heart bulge
  final center = size / 2;
  
  // Custom drawing - Pulse line
  void drawThickLine(int x1, int y1, int x2, int y2, int thickness, img.Color color) {
    for (var i = -thickness ~/ 2; i <= thickness ~/ 2; i++) {
      img.drawLine(image, x1: x1, y1: y1 + i, x2: x2, y2: y2 + i, color: color);
    }
  }

  // Define points for a pulse line with a heart-like peak
  final points = [
    [150, 512],
    [300, 512],
    [350, 400],
    [400, 650],
    [450, 300], // Heart top peak
    [512, 550], // Heart bottom
    [574, 300], // Heart top peak
    [624, 650],
    [674, 400],
    [724, 512],
    [874, 512],
  ];

  for (var i = 0; i < points.length - 1; i++) {
    drawThickLine(
      points[i][0].toInt(), points[i][1].toInt(),
      points[i+1][0].toInt(), points[i+1][1].toInt(),
      40, white
    );
  }

  // 4. Save the generated image
  File('assets/icon/icon.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(image));

  print('Icon generated successfully at assets/icon/icon.png');
}
