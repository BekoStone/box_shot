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
    
    // ✅ NEW: Play pickup sound effect
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
    
    final scene = gameRef.children.whereType<GameScene>().first;

    // ✅ IMPROVED: Use new precise snap position calculation
    final snapPosition = scene.getSnapPosition(absolutePosition);

    // Check collision with other active blocks
    for (final other in scene.activeBlocks) {
      if (other != this && toRect().overlaps(other.toRect())) {
        position = originalPosition.clone();
        // ✅ NEW: Play error sound for invalid placement
        AssetManager.playSfx('sfx_error');
        return;
      }
    }

    // Check if block can be placed at snap position
    if (!scene.canPlaceBlock(this, snapPosition)) {
      position = originalPosition.clone();
      // ✅ NEW: Play error sound for invalid placement
      AssetManager.playSfx('sfx_error');
      return;
    }

    // ✅ IMPROVED: Precise positioning relative to scene
    position = snapPosition - scene.position;
    isLocked = true;

    // ✅ NEW: Play successful placement sound
    AssetManager.playSfx('sfx_drop');

    // Mark grid cells as occupied
    scene.markBlockOccupied(this, snapPosition);
    scene.activeBlocks.remove(this);

    // ✅ FIX: Update original position to prevent visual duplication
    originalPosition = position.clone();

    // Spawn new blocks if all are placed
    if (scene.activeBlocks.isEmpty) {
      scene.spawnThreeBlocks();
    }

    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (isLocked) return;
    
    _isDragging = false;
    priority = 1; // Return to normal priority
    position = originalPosition.clone();
    
    // ✅ NEW: Play cancel sound
    AssetManager.playSfx('sfx_error');
    
    super.onDragCancel(event);
  }

  // ✅ NEW: Reset to original position (for undo)
  void resetToOriginal() {
    position = originalPosition.clone();
    isLocked = false;
    _isDragging = false;
    priority = 1;
  }

  // ✅ NEW: Update original position (when block spawns)
  void updateOriginalPosition(Vector2 newPosition) {
    originalPosition = newPosition.clone();
    position = newPosition.clone();
  }

  // ✅ NEW: Get bounding rectangle for collision detection
  Rect toRect() {
    return Rect.fromLTWH(
      absolutePosition.x,
      absolutePosition.y,
      size.x,
      size.y,
    );
  }

  // ✅ NEW: Visual feedback for dragging
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

  // ✅ NEW: Check if block can be placed anywhere (for game over detection)
  bool canBePlacedAnywhere(GameScene scene) {
    const int extendedGridSize = GameScene.extendedGridSize;
    
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        final testPosition = scene.gridPositions[row][col];
        if (scene.canPlaceBlock(this, testPosition)) {
          return true;
        }
      }
    }
    return false;
  }

  // ✅ NEW: Get number of cells in this block
  int get cellCount {
    int count = 0;
    for (final row in shape) {
      for (final cell in row) {
        if (cell == 1) count++;
      }
    }
    return count;
  }

  // ✅ NEW: Get shape dimensions
  Vector2 get shapeDimensions {
    return Vector2(shape[0].length.toDouble(), shape.length.toDouble());
  }
}