import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Persistent bottom navigation shell shared across all tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    AppRoutes.home,
    AppRoutes.markets,
    '', // trade – special centre button
    AppRoutes.portfolio,
    AppRoutes.profile,
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/trade')) return 2;
    final idx = _tabs.indexOf(loc);
    return idx < 0 ? 0 : idx;
  }

  void _onTap(BuildContext context, int i) {
    if (i == 2) {
      // Trade shows a stock-picker; for now go to markets
      context.go(AppRoutes.markets);
      return;
    }
    context.go(_tabs[i]);
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: _AppBottomNav(
        currentIndex: current,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.bgApp.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NavItem(
              icon: '🏠',
              label: 'الرئيسية',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: '📊',
              label: 'الأسواق',
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _TradeNavItem(onTap: () => onTap(2)),
            _NavItem(
              icon: '💼',
              label: 'محفظتي',
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: '👤',
              label: 'حسابي',
              selected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 20.sp,
                shadows: selected
                    ? [
                        const Shadow(
                          color: AppColors.green,
                          blurRadius: 8,
                        )
                      ]
                    : null,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? AppColors.green : AppColors.text3,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradeNavItem extends StatelessWidget {
  const _TradeNavItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, -16.h),
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x590B7A5E),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text('⚡', style: TextStyle(fontSize: 22.sp)),
              ),
            ),
          ),
          Text(
            'تداول',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
