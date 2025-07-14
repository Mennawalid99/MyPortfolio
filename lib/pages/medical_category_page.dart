import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/event_model.dart';
import '../category_page.dart';

class MedicalCategoryPage extends StatelessWidget {
  final List<Event> events;

  const MedicalCategoryPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CategoryPage(
      categoryName: 'Medical',
      categoryIcon: Iconsax.health,
      events: events,
    );
  }
}
