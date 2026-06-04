import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warehouse_amf/utils/consts/durations.dart';

class OrdersLoadingWidget extends StatelessWidget {
  const OrdersLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
        duration: kShimmerDuration,
        baseColor: Theme.of(context).colorScheme.surfaceContainerLow,
        highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ListView.separated(
        itemCount: 10,
        itemBuilder: (context, index) => Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
          child: Column(
            children: [
              const Spacer(),
              detailRow(),
              const Divider(),
              detailRow(),
              const Divider(),
              detailRow(),
              const Divider(),
              detailRow(),
              const Divider(),
              detailRow(),
              const Spacer(),
              InkWell(
                onTap: () {},
                splashColor: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     
                      Text(
                        "FakeFakle",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(
          height: 10,
        ),
      ),
    );
  }

  Row detailRow() {
    return const Row(
      children: [
        SizedBox(width: 5),
        Text(
          "tidsfsfsdfsdfsdftle",
        ),
        Spacer(),
        Icon(
          Icons.abc,
        ),
        SizedBox(width: 5),
      ],
    );
  }
}
