import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/event_model.dart';
import '../category_page.dart';

class CarsCategoryPage extends StatelessWidget {
  final List<Event> events;

  const CarsCategoryPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CategoryPage(
      categoryName: 'Cars',
      categoryIcon: Iconsax.car,
      events: events,
    );
  }
}
