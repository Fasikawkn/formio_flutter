/// A Flutter widget that renders tabbed navigation for form sections
/// based on a Form.io "tabs" component.
///
/// Each tab can contain one or more form components. Tabs are switched
/// dynamically and data for each tab is tracked independently.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class TabsComponent extends StatefulWidget {
  /// The Form.io component definition for the tabs.
  final ComponentModel component;

  /// Form value map for all child components across tabs.
  final Map<String, dynamic> value;

  /// Callback triggered when any child component's value changes.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const TabsComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged})
      : super(key: key);

  @override
  State<TabsComponent> createState() => _TabsComponentState();
}

class _TabsComponentState extends State<TabsComponent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<dynamic> _tabsRaw;
  late List<String> _tabLabels;
  final List<GlobalKey> _tabKeys = [];

  @override
  void initState() {
    super.initState();
    _tabsRaw = widget.component.raw['components'] as List? ?? [];
    _tabLabels =
        _tabsRaw.map((tab) => tab['label']?.toString() ?? 'Tab').toList();
    _tabController = TabController(length: _tabsRaw.length, vsync: this);

    // Create a GlobalKey for each tab to measure its height
    for (int i = 0; i < _tabsRaw.length; i++) {
      _tabKeys.add(GlobalKey());
    }
  }

  List<ComponentModel> _getTabComponents(int index) {
    final components = _tabsRaw[index]['components'] as List? ?? [];
    return components.map((c) => ComponentModel.fromJson(c)).toList();
  }

  void _updateField(String key, dynamic newValue) {
    final updated = Map<String, dynamic>.from(widget.value);
    updated[key] = newValue;
    widget.onChanged(updated);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabsRaw.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _AdaptiveTabBarView(
              controller: _tabController,
              children: List.generate(_tabsRaw.length, (index) {
                final components = _getTabComponents(index);
                return Column(
                  key: _tabKeys[index],
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: components
                      .map(
                        (comp) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ComponentFactory.build(
                              component: comp,
                              value: widget.value[comp.key],
                              onChanged: (val) => _updateField(comp.key, val)),
                        ),
                      )
                      .toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom TabBarView that adapts its height based on the current tab's content
class _AdaptiveTabBarView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;

  const _AdaptiveTabBarView({
    Key? key,
    required this.controller,
    required this.children,
  }) : super(key: key);

  @override
  State<_AdaptiveTabBarView> createState() => _AdaptiveTabBarViewState();
}

class _AdaptiveTabBarViewState extends State<_AdaptiveTabBarView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: SizedBox(
        width: double.infinity,
        child: IndexedStack(
          index: widget.controller.index,
          children: widget.children,
        ),
      ),
    );
  }
}
