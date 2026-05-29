import 'dart:io';

import 'package:image/image.dart' as img;

const int _outputSize = 1024;

void main() {
  stdout.writeln('Generating DoctorsChamber app icon...');
  _writePng(_buildLegacyIcon(), 'assets/icon/app_icon.png');
  _writePng(_buildForegroundIcon(), 'assets/icon/app_icon_foreground.png');
  stdout.writeln('Done.');
}

img.Image _buildLegacyIcon() {
  final canvas = img.Image(width: _outputSize, height: _outputSize);
  final teal = img.ColorRgb8(14, 165, 164);
  img.fill(canvas, color: teal);
  _drawMonogram(canvas, cutoutColor: teal);
  return canvas;
}

img.Image _buildForegroundIcon() {
  final canvas = img.Image(width: _outputSize, height: _outputSize, numChannels: 4);
  final transparent = img.ColorRgba8(0, 0, 0, 0);
  _drawMonogram(canvas, cutoutColor: transparent);
  return canvas;
}

/// Draws a bold geometric "DP" monogram in white at the centre of [canvas].
/// Both letters are 200×510px, drawn with stroke-width ~80px so they read
/// clearly at any launcher icon size.
void _drawMonogram(img.Image canvas, {required img.Color cutoutColor}) {
  final white = img.ColorRgb8(255, 255, 255);

  // Letters span x=270..760, y=260..770 (centred on 1024×1024).

  // ---- D : flat left side, rounded right side, hollow interior ----------
  // Outer rounded rect (white) — all corners rounded.
  img.fillRect(
    canvas,
    x1: 270,
    y1: 260,
    x2: 490,
    y2: 770,
    color: white,
    radius: 80,
  );
  // Flatten the LEFT corners by filling the rounded gaps with white.
  img.fillRect(canvas,
      x1: 270, y1: 260, x2: 360, y2: 350, color: white);
  img.fillRect(canvas,
      x1: 270, y1: 680, x2: 360, y2: 770, color: white);
  // Inner cutout — the "hole" of the D, with the stem on its left.
  img.fillRect(
    canvas,
    x1: 360,
    y1: 340,
    x2: 440,
    y2: 690,
    color: cutoutColor,
    radius: 30,
  );

  // ---- P : stem + bowl ---------------------------------------------------
  // Bowl outer (top portion) — rounded.
  img.fillRect(
    canvas,
    x1: 540,
    y1: 260,
    x2: 760,
    y2: 580,
    color: white,
    radius: 70,
  );
  // Flatten LEFT corners of the bowl so the stem reads as a flat edge.
  img.fillRect(canvas,
      x1: 540, y1: 260, x2: 620, y2: 330, color: white);
  img.fillRect(canvas,
      x1: 540, y1: 510, x2: 620, y2: 580, color: white);
  // Bowl inner cutout.
  img.fillRect(
    canvas,
    x1: 620,
    y1: 340,
    x2: 720,
    y2: 500,
    color: cutoutColor,
    radius: 25,
  );
  // Stem of the P — extends from top of bowl down to baseline.
  img.fillRect(
    canvas,
    x1: 540,
    y1: 260,
    x2: 620,
    y2: 770,
    color: white,
  );
}

void _writePng(img.Image image, String relativePath) {
  final bytes = img.encodePng(image);
  final file = File(relativePath);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
  stdout.writeln('  ${file.path} (${bytes.length} bytes)');
}
