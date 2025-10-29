import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

class MealItemSkeleton extends StatelessWidget {
  const MealItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const SkeletonLoader(width: 40, height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(width: 120, height: 16),
                SizedBox(height: 6),
                SkeletonLoader(width: 80, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SkeletonLoader(width: 48, height: 48),
        ],
      ),
    );
  }
}

