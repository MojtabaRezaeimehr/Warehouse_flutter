import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warehouse_amf/utils/consts/durations.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class StartingOrderStateWidget extends StatelessWidget {
  const StartingOrderStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
        duration: kShimmerDuration,
        baseColor: Theme.of(context).colorScheme.surfaceContainerLow,
        highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 10),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      width: 60,
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh),
                      child: const Text("000"),
                    ),
                    Container(
                      height: 40,
                      width: 200,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(Translations.scannedCount.name.tr()),
                          const Text("456"),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh),
                      child: const Text("5ms"),
                    ),
                  ],
                ),
                Container(
                  height: 50,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHigh),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Translations.uid.name.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        "3546683244543248652",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Skeleton.leaf(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 5,
                  children: [
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        fixedSize: const Size(90, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: null,
                      icon: const Icon(Icons.add),
                    ),
                    Expanded(
                      child: IconButton.outlined(
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: null,
                        icon: const Icon(Icons.qr_code_scanner),
                      ),
                    ),
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        fixedSize: const Size(90, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: null,
                    child: Text(Translations.finish.name.tr()),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
