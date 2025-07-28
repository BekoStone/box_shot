import 'package:flutter/material.dart';
import '../../game/managers/power_up_manager.dart';

class PowerUpMenuOverlay extends StatefulWidget {
  final Function(PowerUpType) onPowerUpSelected;
  final Function() onCancel;
  final Map<PowerUpType, int> inventory;
  final int currentCoins;

  const PowerUpMenuOverlay({
    super.key,
    required this.onPowerUpSelected,
    required this.onCancel,
    required this.inventory,
    required this.currentCoins,
  });

  @override
  State<PowerUpMenuOverlay> createState() => _PowerUpMenuOverlayState();
}

class _PowerUpMenuOverlayState extends State<PowerUpMenuOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(230),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.purple.withAlpha(179), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🔥 POWER-UPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '💰 ${widget.currentCoins}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Instructions
            const Text(
              'Tap a power-up to use it, then click where you want to use it on the grid',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            
            // Power-up buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: PowerUpManager.powerUps.entries.map((entry) {
                final type = entry.key;
                final data = entry.value;
                final count = widget.inventory[type] ?? 0;
                final hasItem = count > 0;
                
                return GestureDetector(
                  onTap: hasItem ? () => widget.onPowerUpSelected(type) : null,
                  child: Container(
                    width: 85,
                    height: 100,
                    decoration: BoxDecoration(
                      color: hasItem 
                          ? data.color.withAlpha(77)
                          : Colors.grey.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasItem ? data.color : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.name.toUpperCase(),
                          style: TextStyle(
                            color: hasItem ? Colors.white : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: hasItem ? data.color.withAlpha(204) : Colors.grey.withAlpha(128),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.description,
                          style: TextStyle(
                            color: hasItem ? Colors.white70 : Colors.grey.shade600,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '✕ CLOSE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onCancel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '🛒 BUY MORE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}