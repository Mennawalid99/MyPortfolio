import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/event_model.dart';
import '../category_page.dart';

class MusicCategoryPage extends StatelessWidget {
  final List<Event> events;

  const MusicCategoryPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CategoryPage(
      categoryName: 'Music',
      categoryIcon: Iconsax.music,
      events: events,
    );
  }
}
