import 'package:flutter/material.dart';
import 'package:flutter_application_1/tab_feature/tab_bar/tab_bar.dart';
import 'package:flutter_application_1/tab_feature/tab_page/tab_page.dart';

class CustomSystemTabScreen extends StatefulWidget {
  const CustomSystemTabScreen({super.key});

  @override
  State<CustomSystemTabScreen> createState() => _CustomSystemTabScreenState();
}

class _CustomSystemTabScreenState extends State<CustomSystemTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Home', 'Explore', 'Settings', 'Profile'];

  // Maintain separate scroll positions for each individual tab
  final Map<int, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    for (int i = 0; i < _tabs.length; i++) {
      _scrollControllers[i] = ScrollController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTabTap(int index) {
    if (_tabController.index == index) {
      // Tap active tab: Native smooth scroll back to top (No page changes)
      _scrollControllers[index]?.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Rapid taps override: The newest tap wins natively
      _tabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.of(context).accessibleNavigation ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

    return Scaffold(
      appBar: AppBar(
        // Header stays perfectly still. Swaps instantly with no content transition.
        title: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return Text('Header: ${_tabs[_tabController.index]}');
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: CustomStretchTabBar(
              controller: _tabController,
              tabs: _tabs,
              onTabTap: _handleTabTap,
              reduceMotion: reduceMotion,
            ),
          ),
          Expanded(
            child: CustomTabPageView(
              controller: _tabController,
              scrollControllers: _scrollControllers,
              reduceMotion: reduceMotion,
            ),
          ),
        ],
      ),
    );
  }
}
