import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/kyc_steps_bar.dart';

class KycReviewScreen extends StatefulWidget {
  const KycReviewScreen({super.key});

  @override
  State<KycReviewScreen> createState() => _KycReviewScreenState();
}

class _KycReviewScreenState extends State<KycReviewScreen> {
  bool _termsAccepted = true;
  bool _shariaAccepted = true;
  bool _dataAccepted = true;
  bool _riskAccepted = true;

  bool get _allAccepted =>
      _termsAccepted && _shariaAccepted && _dataAccepted && _riskAccepted;

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
          'مراجعة وتأكيد الطلب',
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
              const KycStepsBar(activeIndex: 4, doneCount: 4),
              SizedBox(height: 20.h),
              // Hero
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Text('✅', style: TextStyle(fontSize: 36.sp)),
                    SizedBox(height: 8.h),
                    Text(
                      'الخطوة الأخيرة',
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.white),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'راجع معلوماتك قبل الإرسال النهائي',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.white.withOpacity(0.85)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              // Personal info
              _SectionCard(
                title: 'البيانات الشخصية',
                icon: '👤',
                rows: const [
                  ['الاسم الكامل', 'محمد عبدالله الراشد'],
                  ['رقم الهوية', '1098765432'],
                  ['تاريخ الميلاد', '1990/06/15'],
                  ['الجنسية', 'سعودي'],
                  ['الجوال', '+966 55 123 4567'],
                  ['البريد الإلكتروني', 'mohammed@example.com'],
                ],
              ),
              SizedBox(height: 14.h),
              // Bank info
              _SectionCard(
                title: 'الحساب البنكي',
                icon: '🏦',
                rows: const [
                  ['البنك', 'بنك العربي الوطني'],
                  ['رقم الآيبان', 'SA44 2000 0001 ***** 1234'],
                  ['صاحب الحساب', 'محمد عبدالله الراشد'],
                ],
              ),
              SizedBox(height: 20.h),
              // Terms
              Text(
                'الموافقات والإقرارات',
                style:
                    AppTextStyles.sectionTitle.copyWith(color: AppColors.text1),
              ),
              SizedBox(height: 12.h),
              _TermsRow(
                text: 'أوافق على الشروط والأحكام وسياسة الخصوصية',
                value: _termsAccepted,
                onChanged: (v) => setState(() => _termsAccepted = v ?? false),
              ),
              _TermsRow(
                text: 'أقر بأن المنتجات المختارة متوافقة مع أحكام الشريعة',
                value: _shariaAccepted,
                onChanged: (v) => setState(() => _shariaAccepted = v ?? false),
              ),
              _TermsRow(
                text: 'أوافق على مشاركة بياناتي مع الجهات التنظيمية',
                value: _dataAccepted,
                onChanged: (v) => setState(() => _dataAccepted = v ?? false),
              ),
              _TermsRow(
                text: 'أقر بفهم مخاطر الاستثمار والتقلبات في السوق',
                value: _riskAccepted,
                onChanged: (v) => setState(() => _riskAccepted = v ?? false),
              ),
              SizedBox(height: 28.h),
              GestureDetector(
                onTap: _allAccepted
                    ? () => context.push(AppRoutes.kycSubmitted)
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    gradient:
                        _allAccepted ? AppColors.primaryGradient : null,
                    color: _allAccepted ? null : AppColors.border,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'إرسال طلب فتح الحساب',
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.white),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final String icon;
  final List<List<String>> rows;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Text(icon, style: TextStyle(fontSize: 18.sp)),
                SizedBox(width: 8.w),
                Text(title,
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.text1)),
                const Spacer(),
                Text(
                  'تعديل',
                  style: AppTextStyles.caption.copyWith(color: AppColors.green),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(rows[i][0],
                      style:
                          AppTextStyles.bodySm.copyWith(color: AppColors.text3)),
                  Text(rows[i][1],
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.text1)),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(
                  height: 1,
                  color: AppColors.border.withOpacity(0.5),
                  indent: 14,
                  endIndent: 14),
          ],
        ],
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TermsRow({
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.green,
            side: BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r)),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Text(
                text,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.text2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
