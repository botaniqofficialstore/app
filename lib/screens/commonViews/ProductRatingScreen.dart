import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../CodeReusable/CodeReusability.dart';
import '../../constants/ConstantVariables.dart';

class ProductRatingScreen extends StatefulWidget {
  const ProductRatingScreen({super.key});

  @override
  State<ProductRatingScreen> createState() => ProductRatingScreenState();
}

class ProductRatingScreenState extends State<ProductRatingScreen>
    with TickerProviderStateMixin {
  static const int _maxBenefitLength = 300;
  late TextEditingController reviewTextController;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    reviewTextController = TextEditingController();
  }

  @override
  void dispose() {
    reviewTextController.dispose();
    super.dispose();
  }

  void _submitData() {
    Navigator.pop(context, {
      'rating': _selectedRating,
      'review': reviewTextController.text.trim(),
    });
  }


  bool get _isButtonEnabled {
    return _selectedRating > 0 &&
        reviewTextController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => CodeReusability.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          child: Column(
            children: [
              /// Header
              Padding(
                padding: EdgeInsets.only(
                    left: 15.dp, right: 15.dp, top: 5.dp, bottom: 10.dp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      child: Icon(Icons.arrow_back_outlined,
                          color: Colors.black, size: 18.dp),
                    ),
                    SizedBox(width: 5.dp,),
                    objCommonWidgets.customText(
                      context,
                      'Ratings & Reviews',
                      14,
                      Colors.black,
                      objConstantFonts.montserratMedium,
                    ),
                    SizedBox(width: 25.dp),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.dp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.dp),

                        /// ⭐ Description Section
                        _buildSectionFadeIn(
                          delay: 50,
                          child: Column(
                            children: [
                              objCommonWidgets.customText(
                                context,
                                'Share your experience',
                                15,
                                Colors.black,
                                objConstantFonts.montserratSemiBold,
                              ),
                              SizedBox(height: 8.dp),
                              objCommonWidgets.customText(
                                context,
                                'Your feedback helps us improve product quality, delivery speed, and overall service. '
                                    'Please rate the product and share your experience with delivery, packaging, and freshness.',
                                11,
                                Colors.black54,
                                objConstantFonts.montserratMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 35.dp),

                        /// 1. Rating Section
                        _buildSectionFadeIn(
                          delay: 150,
                          child: Column(
                            children: [
                              objCommonWidgets.customText(
                                context,
                                'How was your product & delivery experience?',
                                13,
                                Colors.black,
                                objConstantFonts.montserratSemiBold,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 15.dp),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  bool isSelected = index < _selectedRating;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedRating = index + 1),
                                    child: AnimatedScale(
                                      scale: isSelected ? 1.2 : 1.0,
                                      duration:
                                      const Duration(milliseconds: 200),
                                      curve: Curves.bounceOut,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.dp),
                                        child: Icon(
                                          isSelected
                                              ? Icons.star
                                              : Icons.star_border_rounded,
                                          color: isSelected
                                              ? const Color(0xFFFFD700)
                                              : Colors.black,
                                          size: 25.dp,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40.dp),

                        /// 2. Review TextField
                        _buildSectionFadeIn(
                          delay: 300,
                          child: Stack(
                            children: [
                              TextField(
                                controller: reviewTextController,
                                maxLength: _maxBenefitLength,
                                cursorColor: Colors.deepOrange,
                                minLines: 5,
                                maxLines: null,
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(
                                  fontSize: 12.dp,
                                  color: Colors.black,
                                  fontFamily:
                                  objConstantFonts.montserratMedium,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                  "Write about product quality, freshness, packaging, and delivery experience...",
                                  hintStyle: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 11.dp,
                                    fontFamily:
                                    objConstantFonts.montserratMedium,
                                  ),
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(16.dp),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(12.dp),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.dp),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(12.dp),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange,
                                        width: 1.5.dp),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 15,
                                child: objCommonWidgets.customText(
                                  context,
                                  "${reviewTextController.text.length}/$_maxBenefitLength",
                                  10,
                                  reviewTextController.text.length >=
                                      _maxBenefitLength
                                      ? Colors.red
                                      : Colors.black45,
                                  objConstantFonts.montserratMedium,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30.dp),

                        /// 3. Submit Button
                        _buildSectionFadeIn(
                          delay: 500,
                          child: AnimatedOpacity(
                            duration:
                            const Duration(milliseconds: 300),
                            opacity: _isButtonEnabled ? 1.0 : 0.6,
                            child: SizedBox(
                              width: double.infinity,
                              height: 45.dp,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                color: Colors.deepOrange,
                                disabledColor:
                                Colors.grey.shade400,
                                borderRadius:
                                BorderRadius.circular(25.dp),
                                onPressed:
                                _isButtonEnabled ? _submitData : null,
                                child: objCommonWidgets.customText(
                                  context,
                                  'Submit Review',
                                  14,
                                  Colors.white,
                                  objConstantFonts
                                      .montserratSemiBold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.dp),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fade-in animation helper
  Widget _buildSectionFadeIn(
      {required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
