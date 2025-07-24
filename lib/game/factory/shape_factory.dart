// ✅ File: lib/game/factory/shape_factory.dart

import '../components/block_component.dart';
import 'dart:math';

class ShapeFactory {
  static final _random = Random();

  static BlockComponent generateRandomShape() {
    final shapes = [
      // مربع
      [
        [1, 1],
        [1, 1],
      ],
      // خط عمودي
      [
        [1],
        [1],
        [1],
        [1],
      ],
      // خط أفقي
      [
        [1, 1, 1, 1],
      ],
      // L
      [
        [1, 0],
        [1, 0],
        [1, 1],
      ],
      // J
      [
        [0, 1],
        [0, 1],
        [1, 1],
      ],
      // T
      [
        [1, 1, 1],
        [0, 1, 0],
      ],
      // Z
      [
        [1, 1, 0],
        [0, 1, 1],
      ],
      // S
      [
        [0, 1, 1],
        [1, 1, 0],
      ],
    ];

    return BlockComponent(shape: shapes[_random.nextInt(shapes.length)]);
  }
}



