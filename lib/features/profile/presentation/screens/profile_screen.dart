import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometrics = true;
  bool _shariaFilter = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero header
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 24.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.white.withOpacity(0.3), width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text('👤', style: TextStyle(fontSize: 32.sp)),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'محمد عبدالله الراشد',
                      style: AppTextStyles.h4.copyWith(color: AppColors.white),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '+966 55 123 4567',
                      style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.white.withOpacity(0.8)),
                    ),
                    SizedBox(height: 12.h),
                    // Verified badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: AppColors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 14.r, color: AppColors.white),
                          SizedBox(width: 6.w),
                          Text(
                            'حساب موثق',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Account group
              _SettingsGroup(
                title: 'الحساب',
                items: [
                  _SettingItem(
                    icon: '🪪',
                    label: 'التحقق من الهوية (KYC)',
                    badge: 'موثق',
                    badgeColor: AppColors.green,
                    onTap: () {},
                  ),
                  _SettingItem(
                    icon: '🏦',
                    label: 'الحسابات البنكية',
                    onTap: () {},
                  ),
                  _SettingItem(
                    icon: '📋',
                    label: 'كشف الحساب',
                    onTap: () => context.push(AppRoutes.statement),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Security group
              _SettingsGroup(
                title: 'الأمان',
                items: [
                  _SettingItem(
                    icon: '👁',
                    label: 'البصمة / Face ID',
                    trailing: Switch(
                      value: _biometrics,
                      onChanged: (v) => setState(() => _biometrics = v),
                      activeColor: AppColors.green,
                    ),
                    onTap: () {},
                  ),
                  _SettingItem(
                    icon: '🔢',
                    label: 'تغيير رمز PIN',
                    onTap: () {},
                  ),
                  _SettingItem(
                    icon: '📱',
                    label: 'الأجهزة الموثوقة',
                    badge: '1 جهاز',
                    badgeColor: AppColors.text3,
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Settings group
              _SettingsGroup(
                title: 'الإعدادات',
                items: [
                  _SettingItem(
                    icon: '☽',
                    label: 'الفلتر الشرعي',
                    trailing: Switch(
                      value: _shariaFilter,
                      onChanged: (v) => setState(() => _shariaFilter = v),
                      activeColor: AppColors.green,
                    ),
                    onTap: () {},
                  ),
                  _SettingItem(
                    icon: '🌐',
                    label: 'اللغة',
                    badge: 'عربي',
                    badgeColor: AppColors.text3,
                    onTap: () {},
                  ),
                  _SettingItem(
                    icon: '🎧',
                    label: 'الدعم والمساعدة',
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // Logout
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColors.redLite,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: AppColors.red.withOpacity(0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout_rounded,
                            size: 18.r, color: AppColors.red),
                        SizedBox(width: 8.w),
                        Text(
                          'تسجيل الخروج',
                          style: AppTextStyles.button
                              .copyWith(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Version
              Text(
                'Sanad v1.0.0 — صُنع بـ ❤️ في المملكة',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.text4),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingItem> items;

  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(color: AppColors.text1),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgApp,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: List.generate(items.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return Divider(
                      height: 1,
                      color: AppColors.border.withOpacity(0.5),
                      indent: 50.w);
                }
                return items[i ~/ 2];
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String icon;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.text1),
              ),
            ),
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.text3).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.caption
                      .copyWith(color: badgeColor ?? AppColors.text3),
                ),
              ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14.r, color: AppColors.text4),
          ],
        ),
      ),
    );
  }
}
