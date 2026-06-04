import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_amf/screens/history/history_screen.dart';
import 'package:warehouse_amf/screens/home/widgets/new_order_picker.dart';
import 'package:warehouse_amf/screens/orders/orders_screen_wrapper.dart';
import 'package:warehouse_amf/screens/search/search_screen.dart';

import '../settings/settings_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int activeIndex = 2;
  final _screens = [
    const HistoryPage(),
    const SearchPage(),
    const OrdersScreenWrapper(),
    const SettingsWrapperPage(),
  ];

  final navChildrenData = [
    (Icons.history, "history"),
    (Icons.manage_search, "search"),
    (Icons.toc, "orders"),
    (Icons.settings, "settings"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15),
        child: _screens[activeIndex],
      )),
      floatingActionButton: GestureDetector(
        onLongPress: () {
          //start outgoing order
        },
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return const NewOrderPicker();
              },
            );
          },
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        gapLocation: GapLocation.center,
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        itemCount: navChildrenData.length,
        height: 70,
        notchSmoothness: NotchSmoothness.softEdge,
        splashRadius: 0,
        scaleFactor: 0.2,
        activeIndex: activeIndex,
        onTap: (index) {
          setState(() {
            activeIndex = index;
          });
        },
        tabBuilder: (index, isActive) {
          return InkWell(
            child: Transform.scale(
              scale: isActive ? 1.2 : 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    navChildrenData[index].$1,
                    color: isActive
                        ? Theme.of(context).colorScheme.tertiary
                        : null,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    navChildrenData[index].$2.tr(),
                    style: TextStyle(
                      color: isActive
                          ? Theme.of(context).colorScheme.tertiary
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
