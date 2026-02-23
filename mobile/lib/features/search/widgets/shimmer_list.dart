import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton loading state for the search results list.
///
/// Per RESEARCH Pitfall 6: the ENTIRE list is wrapped in a SINGLE
/// Shimmer.fromColors so all cards animate in sync.
///
/// Wrapped in ExcludeSemantics — shimmer has no semantic meaning
/// per accessibility contract.
class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1E1E1E),
        highlightColor: const Color(0xFF2A2A2A),
        child: Column(
          children: List.generate(5, (_) => const _SkeletonTile()),
        ),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Album art placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          // Text placeholders
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 200,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 140,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
