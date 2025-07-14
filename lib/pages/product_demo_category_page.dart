import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/event_model.dart';
import '../category_page.dart';

class ProductDemoCategoryPage extends StatelessWidget {
  final List<Event> events;

  const ProductDemoCategoryPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CategoryPage(
      categoryName: 'Product-Demo',
      categoryIcon: Iconsax.box,
      events: events,
    );
  }
}
