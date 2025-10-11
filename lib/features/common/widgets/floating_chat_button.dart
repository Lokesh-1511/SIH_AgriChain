import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
<<<<<<< HEAD
import '../../farmer/screens/chat_screen.dart';
=======
import '../screens/chat_screen.dart';
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b

class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      },
      backgroundColor: AppColors.farmerPrimary,
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
=======
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
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
    );
  }
}
