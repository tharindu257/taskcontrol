import 'package:flutter/material.dart';
import '../config/theme.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 32,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppTheme.primaryColor,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
