// File: lib/game/factory/shape_factory.dart

import '../components/block_component.dart';
import 'dart:math';

class ShapeFactory {
  static final _random = Random();

  static BlockComponent generateRandomShape() {
    final shapes = [
      // ✅ BASIC SHAPES (Common)
      
      // Single block
      [
        [1],
      ],
      
      // 2-block shapes
      [
        [1, 1],
      ],
      [
        [1],
        [1],
      ],
      
      // 3-block shapes
      [
        [1, 1, 1],
      ],
      [
        [1],
        [1],
        [1],
      ],
      [
        [1, 1],
        [1, 0],
      ],
      [
        [1, 1],
        [0, 1],
      ],
      [
        [1, 0],
        [1, 1],
      ],
      [
        [0, 1],
        [1, 1],
      ],
      
      // ✅ CLASSIC TETRIS SHAPES
      
      // Square (2x2)
      [
        [1, 1],
        [1, 1],
      ],
      
      // I-piece (line) variations
      [
        [1, 1, 1, 1],
      ],
      [
        [1],
        [1],
        [1],
        [1],
      ],
      
      // L-pieces
      [
        [1, 0],
        [1, 0],
        [1, 1],
      ],
      [
        [0, 1],
        [0, 1],
        [1, 1],
      ],
      [
        [1, 1, 1],
        [1, 0, 0],
      ],
      [
        [1, 1, 1],
        [0, 0, 1],
      ],
      
      // T-pieces
      [
        [1, 1, 1],
        [0, 1, 0],
      ],
      [
        [0, 1],
        [1, 1],
        [0, 1],
      ],
      [
        [0, 1, 0],
        [1, 1, 1],
      ],
      [
        [1, 0],
        [1, 1],
        [1, 0],
      ],
      
      // Z and S pieces
      [
        [1, 1, 0],
        [0, 1, 1],
      ],
      [
        [0, 1, 1],
        [1, 1, 0],
      ],
      [
        [0, 1],
        [1, 1],
        [1, 0],
      ],
      [
        [1, 0],
        [1, 1],
        [0, 1],
      ],
      
      // ✅ UNIQUE PUZZLE SHAPES
      
      // Plus shape
      [
        [0, 1, 0],
        [1, 1, 1],
        [0, 1, 0],
      ],
      
      // Corner shapes
      [
        [1, 1, 1],
        [1, 0, 0],
        [1, 0, 0],
      ],
      [
        [1, 1, 1],
        [0, 0, 1],
        [0, 0, 1],
      ],
      
      // Diagonal shapes
      [
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
      ],
      [
        [0, 0, 1],
        [0, 1, 0],
        [1, 0, 0],
      ],
      
      // Large L shapes
      [
        [1, 0, 0],
        [1, 0, 0],
        [1, 0, 0],
        [1, 1, 1],
      ],
      [
        [0, 0, 1],
        [0, 0, 1],
        [0, 0, 1],
        [1, 1, 1],
      ],
      
      // ✅ ADVANCED SHAPES
      
      // 5-block line
      [
        [1, 1, 1, 1, 1],
      ],
      [
        [1],
        [1],
        [1],
        [1],
        [1],
      ],
      
      // U-shapes
      [
        [1, 0, 1],
        [1, 1, 1],
      ],
      [
        [1, 1],
        [1, 0],
        [1, 1],
      ],
      
      // H-shape
      [
        [1, 0, 1],
        [1, 1, 1],
        [1, 0, 1],
      ],
      
      // Cross variations
      [
        [0, 1],
        [1, 1],
        [0, 1],
        [0, 1],
      ],
      [
        [1, 0],
        [1, 1],
        [1, 0],
        [1, 0],
      ],
      
      // Stair shapes
      [
        [1, 0, 0],
        [1, 1, 0],
        [0, 1, 1],
      ],
      [
        [0, 0, 1],
        [0, 1, 1],
        [1, 1, 0],
      ],
      
      // ✅ SPECIAL CHALLENGE SHAPES
      
      // Large square
      [
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 1],
      ],
      
      // Hollow square
      [
        [1, 1, 1],
        [1, 0, 1],
        [1, 1, 1],
      ],
      
      // Snake shapes
      [
        [1, 1, 0, 0],
        [0, 1, 1, 1],
      ],
      [
        [0, 0, 1, 1],
        [1, 1, 1, 0],
      ],
      
      // Arrow shapes
      [
        [0, 1, 0],
        [1, 1, 1],
        [1, 0, 1],
      ],
      [
        [1, 0, 1],
        [1, 1, 1],
        [0, 1, 0],
      ],
    ];

    return BlockComponent(shape: shapes[_random.nextInt(shapes.length)]);
  }
  
  // ✅ NEW: Generate shape based on difficulty level
  static BlockComponent generateShapeForLevel(int level) {
    // Easy shapes for early levels
    final easyShapes = [
      [[1]], // Single
      [[1, 1]], // 2-line
      [[1], [1]], // 2-vertical
      [[1, 1, 1]], // 3-line
      [[1, 1], [1, 1]], // Square
    ];
    
    // Medium shapes for mid levels
    final mediumShapes = [
      [[1, 0], [1, 0], [1, 1]], // L-shape
      [[1, 1, 1], [0, 1, 0]], // T-shape
      [[1, 1, 0], [0, 1, 1]], // Z-shape
      [[1, 1, 1, 1]], // 4-line
    ];
    
    // Hard shapes for high levels
    final hardShapes = [
      [[0, 1, 0], [1, 1, 1], [0, 1, 0]], // Plus
      [[1, 0, 1], [1, 1, 1]], // U-shape
      [[1, 1, 1], [1, 0, 0], [1, 0, 0]], // Large L
      [[1, 1, 1, 1, 1]], // 5-line
    ];
    
    List<List<List<int>>> shapePool;
    
    if (level <= 3) {
      shapePool = easyShapes;
    } else if (level <= 7) {
      shapePool = [...easyShapes, ...mediumShapes];
    } else {
      shapePool = [...easyShapes, ...mediumShapes, ...hardShapes];
    }
    
    return BlockComponent(shape: shapePool[_random.nextInt(shapePool.length)]);
  }
  
  // ✅ NEW: Get shape count for statistics
  static int getTotalShapeCount() => 50; // Approximate count of all shapes
}