import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../screens/chat_screen.dart';

class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        heroTag: "chat_fab", // Unique hero tag to avoid conflicts
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: AppColors.farmerPrimary,
        elevation: 6,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}
