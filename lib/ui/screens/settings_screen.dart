import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onToggleMusic;
  final VoidCallback onToggleSFX;

  const SettingsScreen({
    super.key,
    required this.onClose,
    required this.onToggleMusic,
    required this.onToggleSFX,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicEnabled = true;
  bool sfxEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(204), // Fixed withOpacity deprecation
      child: Center(
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 40, 40, 40),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromARGB(255, 28, 150, 215),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 28, 150, 215),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SETTINGS',
                      style: AppTheme.titleStyle.copyWith(fontSize: 24),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Settings Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Music Toggle
                      SettingsTile(
                        icon: Icons.music_note,
                        title: 'Music',
                        value: musicEnabled,
                        onToggle: (value) {
                          setState(() {
                            musicEnabled = value;
                          });
                          widget.onToggleMusic();
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // SFX Toggle
                      SettingsTile(
                        icon: Icons.volume_up,
                        title: 'Sound Effects',
                        value: sfxEnabled,
                        onToggle: (value) {
                          setState(() {
                            sfxEnabled = value;
                          });
                          widget.onToggleSFX();
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Game Info
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'BOX HOOKS',
                              style: AppTheme.titleStyle.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Reset Progress Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            _showResetDialog();
                          },
                          child: const Text(
                            'Reset Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 40, 40, 40),
          title: Text(
            'Reset Progress',
            style: AppTheme.titleStyle.copyWith(fontSize: 20),
          ),
          content: const Text(
            'Are you sure you want to reset all progress? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onClose();
              },
              child: Text(
                'Reset',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onToggle;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onToggle,
            activeColor: const Color.fromARGB(255, 28, 150, 215),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }
}