import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/kyc_steps_bar.dart';

class KycBankLinkScreen extends StatefulWidget {
  const KycBankLinkScreen({super.key});

  @override
  State<KycBankLinkScreen> createState() => _KycBankLinkScreenState();
}

class _KycBankLinkScreenState extends State<KycBankLinkScreen> {
  int _selectedBank = 0;
  final _ibanController = TextEditingController(
    text: 'SA44 2000 0001 2345 6789 1234',
  );
  bool _ibanVerified = true;

  static const _banks = [
    {'name': 'بنك العربي الوطني', 'short': 'ANB', 'icon': '🏦'},
    {'name': 'مصرف الراجحي', 'short': 'RJHI', 'icon': '🏦'},
    {'name': 'بنك ساب', 'short': 'SABB', 'icon': '🏦'},
    {'name': 'بنك فرنسبنك', 'short': 'BSF', 'icon': '🏦'},
  ];

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgApp,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.text1,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'ربط الحساب البنكي',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.text1),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              const KycStepsBar(activeIndex: 3, doneCount: 3),
              SizedBox(height: 28.h),
              // Absher quick link
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Text('🔐', style: TextStyle(fontSize: 22.sp)),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الربط السريع عبر أبشر',
                            style: AppTextStyles.labelMd
                                .copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'ربط تلقائي آمن بدون إدخال يدوي',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 16.r, color: AppColors.white),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'أو اختر بنكك',
                style: AppTextStyles.sectionTitle.copyWith(color: AppColors.text1),
              ),
              SizedBox(height: 12.h),
              // Bank cards grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _banks.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, i) {
                  final bank = _banks[i];
                  final selected = _selectedBank == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBank = i),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected ? AppColors.greenLite : AppColors.bgApp,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: selected ? AppColors.green : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      child: Row(
                        children: [
                          Text(bank['icon']!,
                              style: TextStyle(fontSize: 20.sp)),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  bank['short']!,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: selected
                                        ? AppColors.green
                                        : AppColors.text1,
                                  ),
                                ),
                                Text(
                                  bank['name']!,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.text3),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle_rounded,
                                size: 16.r, color: AppColors.green),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              // IBAN input
              Text(
                'رقم الآيبان (IBAN)',
                style: AppTextStyles.sectionTitle.copyWith(color: AppColors.text1),
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgApp,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _ibanVerified ? AppColors.green : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ibanController,
                        style: AppTextStyles.monoSm
                            .copyWith(color: AppColors.text1),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 14.h),
                          hintText: 'SA00 0000 0000 0000 0000 0000',
                          hintStyle: AppTextStyles.monoSm
                              .copyWith(color: AppColors.text4),
                        ),
                      ),
                    ),
                    if (_ibanVerified)
                      Padding(
                        padding: EdgeInsets.only(left: 14.w),
                        child: Icon(Icons.verified_rounded,
                            color: AppColors.green, size: 20.r),
                      ),
                    SizedBox(width: 12.w),
                  ],
                ),
              ),
              if (_ibanVerified)
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 12.r, color: AppColors.green),
                      SizedBox(width: 6.w),
                      Text(
                        'آيبان محقق — بنك العربي الوطني',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.green),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 32.h),
              GestureDetector(
                onTap: () => context.push(AppRoutes.kycReview),
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'متابعة',
                    style:
                        AppTextStyles.button.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
