import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warehouse_amf/screens/widgets/info_card.dart';
import 'package:warehouse_amf/utils/consts/durations.dart';

class SearchLoadingWidget extends StatelessWidget {
  const SearchLoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
        duration: kShimmerDuration,
        baseColor: Theme.of(context).colorScheme.surfaceContainerLow,
        highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ListView.separated(
        itemBuilder: (context, index) {
          return const InfoCard(title: "faefrdewqffaefrdewq", desc: "15456546453");
        },
        separatorBuilder: (context, index) => const SizedBox(height: 5),
        itemCount: 10,
      ),
    );
  }
}
