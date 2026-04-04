import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/wallet_local_datasource.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _methods = WalletLocalDataSource().getDepositMethods();
  int _selectedMethod = 1; // mada default
  String _amount = '0';
  static const _quickAmounts = [500, 1000, 2000, 5000];

  double get _parsedAmount => double.tryParse(_amount) ?? 0;

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
          'إيداع',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.text1),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Amount display
            Container(
              color: AppColors.bgApp,
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  Text(
                    'مبلغ الإيداع',
                    style: AppTextStyles.caption.copyWith(color: AppColors.text3),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Text(
                          'SAR',
                          style: AppTextStyles.labelLg
                              .copyWith(color: AppColors.text3),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _amount,
                        style: AppTextStyles.amtInput
                            .copyWith(color: AppColors.text1),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Container(
                          width: 2,
                          height: 24.h,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Quick add chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickAmounts.map((amt) {
                        return Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _amount = amt.toString()),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: AppColors.bgPage,
                                borderRadius: BorderRadius.circular(20.r),
                                border:
                                    Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '+$amt',
                                style: AppTextStyles.labelSm
                                    .copyWith(color: AppColors.navy),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Payment methods
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('طريقة الإيداع',
                      style: AppTextStyles.sectionTitle
                          .copyWith(color: AppColors.text1)),
                  SizedBox(height: 10.h),
                  ...List.generate(_methods.length, (i) {
                    final method = _methods[i];
                    final selected = _selectedMethod == i;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMethod = i),
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0x060D1B2E)
                                : AppColors.bgApp,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: selected
                                  ? AppColors.navy
                                  : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(method.iconEmoji,
                                  style: TextStyle(fontSize: 22.sp)),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(method.name,
                                        style: AppTextStyles.labelSm
                                            .copyWith(color: AppColors.text1)),
                                    SizedBox(height: 2.h),
                                    Text(method.subtitle,
                                        style: AppTextStyles.caption
                                            .copyWith(color: AppColors.text3)),
                                  ],
                                ),
                              ),
                              if (method.isFast)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueLite,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text('فوري',
                                      style: AppTextStyles.caption
                                          .copyWith(color: AppColors.blue)),
                                ),
                              SizedBox(width: 8.w),
                              if (selected)
                                Icon(Icons.check_circle_rounded,
                                    color: AppColors.navy, size: 18.r),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: GestureDetector(
                onTap: _parsedAmount > 0 ? () {} : null,
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    gradient: _parsedAmount > 0
                        ? AppColors.primaryGradient
                        : null,
                    color: _parsedAmount > 0 ? null : AppColors.border,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _parsedAmount > 0
                        ? 'إيداع SAR ${_amount}'
                        : 'أدخل المبلغ',
                    style:
                        AppTextStyles.button.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
