// ✅ NEW: Power-up Store Overlay for purchasing power-ups with coins
import 'package:flutter/material.dart';
class PowerUpStoreOverlay extends StatefulWidget {
  final int currentCoins;
  final Map<dynamic, int> inventory;
  final Function(dynamic) onPurchase;
  final VoidCallback onClose;

  const PowerUpStoreOverlay({
    super.key,
    required this.currentCoins,
    required this.inventory,
    required this.onPurchase,
    required this.onClose,
  });

  @override
  State<PowerUpStoreOverlay> createState() => _PowerUpStoreOverlayState();
}

class _PowerUpStoreOverlayState extends State<PowerUpStoreOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(230),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2876D7),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // ✅ Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF2876D7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🛒 POWER-UP STORE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '💰 ${widget.currentCoins}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // ✅ Store Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Purchase power-ups with coins to help you in difficult situations!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      
                      // ✅ Power-up Grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: 5, // Number of power-ups
                          itemBuilder: (context, index) {
                            // This would map to actual PowerUpType values
                            final powerUpNames = ['Hammer', 'Bomb', 'Shuffle', 'Hint', 'Freeze'];
                            final powerUpIcons = ['🔨', '💣', '🔄', '💡', '❄️'];
                            final powerUpPrices = [50, 100, 75, 25, 30];
                            final powerUpDescriptions = [
                              'Destroy single block',
                              'Clear 3x3 area',
                              'Get new blocks',
                              'Show best move',
                              'Pause and think',
                            ];
                            
                            final name = powerUpNames[index];
                            final icon = powerUpIcons[index];
                            final price = powerUpPrices[index];
                            final description = powerUpDescriptions[index];
                            final canAfford = widget.currentCoins >= price;
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: canAfford 
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: canAfford 
                                      ? const Color(0xFF2876D7)
                                      : Colors.grey.shade600,
                                  width: 2,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: canAfford 
                                      ? () {
                                          // widget.onPurchase(powerUpType);
                                          // For now, just show a message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Purchased $name!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          icon,
                                          style: const TextStyle(fontSize: 36),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          name,
                                          style: TextStyle(
                                            color: canAfford ? Colors.white : Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          description,
                                          style: TextStyle(
                                            color: canAfford ? Colors.white70 : Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: canAfford 
                                                ? Colors.amber.withAlpha(51)
                                                : Colors.grey.withAlpha(51),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '💰 $price',
                                            style: TextStyle(
                                              color: canAfford ? Colors.amber : Colors.grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // ✅ Footer Info
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(26),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blue.withAlpha(77),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tip: Earn coins by placing blocks, clearing lines, and achieving combos!',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}