import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Category card for search/explore grid
class CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Default categories data
class SearchCategories {
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Home Decor', 'icon': Icons.home_outlined, 'color': 0xFF9B59B6},
    {'name': 'Fashion', 'icon': Icons.checkroom_outlined, 'color': 0xFFE91E63},
    {
      'name': 'Food & Drink',
      'icon': Icons.restaurant_outlined,
      'color': 0xFFFF9800,
    },
    {'name': 'Art', 'icon': Icons.palette_outlined, 'color': 0xFF3498DB},
    {'name': 'Travel', 'icon': Icons.flight_outlined, 'color': 0xFF2ECC71},
    {'name': 'Beauty', 'icon': Icons.face_outlined, 'color': 0xFFE74C3C},
    {'name': 'DIY', 'icon': Icons.build_outlined, 'color': 0xFF1ABC9C},
    {
      'name': 'Fitness',
      'icon': Icons.fitness_center_outlined,
      'color': 0xFF34495E,
    },
  ];

  static const List<String> trendingSearches = [
    'Aesthetic wallpaper',
    'Nail designs',
    'Outfit ideas',
    'Room decor',
    'Hairstyles',
    'Recipes',
    'Tattoo ideas',
    'Wedding',
  ];
}
