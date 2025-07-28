// File: lib/game/components/block_component.dart - FIXED VERSION

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import '../../services/asset_manager.dart';
import 'game_scene.dart';

class BlockComponent extends PositionComponent
    with HasGameRef<BoxHooksGame>, DragCallbacks {
  static const double cellSize = 36;
  static const double spacing = 3;

  final List<List<int>> shape;
  bool isLocked = false;
  late Vector2 originalPosition;
  bool _isDragging = false;

  // ✅ FIXED: Better collision detection with improved precision
  static const double _collisionTolerance = 1.0;

  BlockComponent({required this.shape}) {
    final width = shape[0].length;
    final height = shape.length;

    size = Vector2(
      width * (cellSize + spacing) - spacing,
      height * (cellSize + spacing) - spacing,
    );

    priority = 1;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    originalPosition = position.clone();

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          final square = RectangleComponent(
            position: Vector2(
              col * (cellSize + spacing),
              row * (cellSize + spacing),
            ),
            size: Vector2(cellSize, cellSize),
            paint: Paint()..color = Colors.deepPurpleAccent,
          );
          add(square);
        }
      }
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (isLocked) return;
    
    _isDragging = true;
    priority = 10; // Bring to front while dragging
    
    AssetManager.playSfx('sfx_click');
    
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isLocked) return;
    position += event.localDelta;
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (isLocked) return;
    
    _isDragging = false;
    priority = 1; // Return to normal priority
    
    // ✅ FIXED: Safe scene access
    final scenes = gameRef.children.whereType<GameScene>();
    if (scenes.isEmpty) {
      position = originalPosition.clone();
      AssetManager.playSfx('sfx_error');
      return;
    }
    
    final scene = scenes.first;

    // Get precise snap position
    final snapPosition = scene.getSnapPosition(absolutePosition);

    // ✅ FIXED: More robust collision detection with other active blocks
    if (_hasCollisionWithActiveBlocks(scene, snapPosition)) {
      position = originalPosition.clone();
      AssetManager.playSfx('sfx_error');
      return;
    }

    // Check if block can be placed at snap position
    if (!scene.canPlaceBlock(this, snapPosition)) {
      position = originalPosition.clone();
      AssetManager.playSfx('sfx_error');
      return;
    }

    // ✅ FIXED: More precise positioning relative to scene
    position = snapPosition - scene.position;
    isLocked = true;

    AssetManager.playSfx('sfx_drop');

    // Mark grid cells as occupied
    scene.markBlockOccupied(this, snapPosition);
    scene.activeBlocks.remove(this);

    // Update original position to prevent visual duplication
    originalPosition = position.clone();

    // Spawn new blocks if all are placed
    if (scene.activeBlocks.isEmpty) {
      scene.spawnThreeBlocks();
    }

    super.onDragEnd(event);
  }

  // ✅ FIXED: Improved collision detection with tolerance
  bool _hasCollisionWithActiveBlocks(GameScene scene, Vector2 snapPosition) {
    final futureRect = _getRectAtPosition(snapPosition);
    
    for (final other in scene.activeBlocks) {
      if (other != this && !other.isLocked) {
        final otherRect = other.toRect();
        if (_rectsOverlapWithTolerance(futureRect, otherRect)) {
          return true;
        }
      }
    }
    return false;
  }

  // ✅ FIXED: Better rectangle overlap detection with tolerance
  bool _rectsOverlapWithTolerance(Rect rect1, Rect rect2) {
    return rect1.left < rect2.right - _collisionTolerance &&
           rect2.left < rect1.right - _collisionTolerance &&
           rect1.top < rect2.bottom - _collisionTolerance &&
           rect2.top < rect1.bottom - _collisionTolerance;
  }

  // ✅ FIXED: Helper method to get rectangle at specific position
  Rect _getRectAtPosition(Vector2 pos) {
    return Rect.fromLTWH(
      pos.x,
      pos.y,
      size.x,
      size.y,
    );
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (isLocked) return;
    
    _isDragging = false;
    priority = 1; // Return to normal priority
    position = originalPosition.clone();
    
    AssetManager.playSfx('sfx_error');
    
    super.onDragCancel(event);
  }

  void resetToOriginal() {
    position = originalPosition.clone();
    isLocked = false;
    _isDragging = false;
    priority = 1;
  }

  void updateOriginalPosition(Vector2 newPosition) {
    originalPosition = newPosition.clone();
    position = newPosition.clone();
  }

  // ✅ FIXED: More precise bounding rectangle calculation
  Rect toRect() {
    return Rect.fromLTWH(
      absolutePosition.x,
      absolutePosition.y,
      size.x,
      size.y,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Add subtle glow effect when dragging
    if (_isDragging) {
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          const Radius.circular(4),
        ),
        glowPaint,
      );
    }
  }

  // ✅ FIXED: More comprehensive placement checking
  bool canBePlacedAnywhere(GameScene scene) {
    const int extendedGridSize = GameScene.extendedGridSize;
    
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        final testPosition = scene.gridPositions[row][col];
        if (scene.canPlaceBlock(this, testPosition) && 
            !_hasCollisionWithActiveBlocks(scene, testPosition)) {
          return true;
        }
      }
    }
    return false;
  }

  int get cellCount {
    int count = 0;
    for (final row in shape) {
      for (final cell in row) {
        if (cell == 1) count++;
      }
    }
    return count;
  }

  Vector2 get shapeDimensions {
    return Vector2(shape[0].length.toDouble(), shape.length.toDouble());
  }
}