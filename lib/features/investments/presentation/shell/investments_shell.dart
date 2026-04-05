import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Persistent bottom navigation shell for the Investments section.
/// Wraps 5 branches: المحفظة | الاكتتابات | المرابحات | الصناديق | الأسهم
class InvestmentsShell extends StatelessWidget {
  const InvestmentsShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // If already on the same branch, navigate to its initial location
      // (pops any sub-pages and resets scroll).
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: navigationShell,
      bottomNavigationBar: _InvestmentsBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

class _InvestmentsBottomNav extends StatelessWidget {
  const _InvestmentsBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavItem>[
    _NavItem(
      label: 'المحفظة',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
    ),
    _NavItem(
      label: 'الاكتتابات',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
    _NavItem(
      label: 'المرابحات',
      icon: Icons.paid_outlined,
      activeIcon: Icons.paid,
    ),
    _NavItem(
      label: 'الصناديق',
      icon: Icons.layers_outlined,
      activeIcon: Icons.layers,
    ),
    _NavItem(
      label: 'الأسهم',
      icon: Icons.show_chart,
      activeIcon: Icons.show_chart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            _items.length,
            (i) => _NavItemWidget(
              item: _items[i],
              selected: currentIndex == i,
              onTap: () => onTap(i),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : AppColors.text3;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              color: color,
              size: 22.sp,
            ),
            SizedBox(height: 3.h),
            Text(
              item.label,
              style: AppTextStyles.caption.copyWith(
                color: color,
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
