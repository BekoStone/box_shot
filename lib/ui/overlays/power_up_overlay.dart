// File: lib/ui/overlays/power_up_overlay.dart

import 'package:flutter/material.dart';
import '../../game/managers/power_up_manager.dart';

class PowerUpOverlay extends StatefulWidget {
  final Function(PowerUpType) onPowerUpSelected;
  final Function() onCancel;
  final Map<PowerUpType, int> inventory;
  final int currentCoins;

  const PowerUpOverlay({
    super.key,
    required this.onPowerUpSelected,
    required this.onCancel,
    required this.inventory,
    required this.currentCoins,
  });

  @override
  State<PowerUpOverlay> createState() => _PowerUpOverlayState();
}

class _PowerUpOverlayState extends State<PowerUpOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '💰 ${widget.currentCoins}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Power-up buttons
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: PowerUpManager.powerUps.entries.map((entry) {
                final type = entry.key;
                final data = entry.value;
                final count = widget.inventory[type] ?? 0;
                final hasItem = count > 0;
                
                return GestureDetector(
                  onTap: hasItem ? () => widget.onPowerUpSelected(type) : null,
                  child: Container(
                    width: 80,
                    height: 90,
                    decoration: BoxDecoration(
                      color: hasItem 
                          ? data.color.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
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
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.name,
                          style: TextStyle(
                            color: hasItem ? Colors.white : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '$count',
                          style: TextStyle(
                            color: hasItem ? data.color : Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 15),
            
            // Close button
            ElevatedButton(
              onPressed: widget.onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('✕ CLOSE'),
            ),
          ],
        ),
      ),
    );
  }
}