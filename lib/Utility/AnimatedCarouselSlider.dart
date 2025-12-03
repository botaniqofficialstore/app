import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_sizer/flutter_sizer.dart';


class AnimatedCarouselSlider extends StatefulWidget {
  final List<String> imageList;
  final String fallbackImage;

  const AnimatedCarouselSlider({
    Key? key,
    required this.imageList,
    required this.fallbackImage,
  }) : super(key: key);

  @override
  _AnimatedCarouselSliderState createState() => _AnimatedCarouselSliderState();
}

class _AnimatedCarouselSliderState extends State<AnimatedCarouselSlider> {
  int currentIndex = 0;
  late CarouselController innerCarouselController;

  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.dp),
            child: CarouselSlider.builder(
              itemCount: widget.imageList.length,
              itemBuilder: (context, index, realIndex) {
                String imagePath = widget.imageList[index];

                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 30,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.dp),
                    child: Padding(
                        padding: EdgeInsets.all(2.dp),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.fill,
                        width: double.infinity,
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 180.dp,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.95,
                onPageChanged: (index, reason) {
                  setState(() => currentIndex = index);
                },
              ),
            ),
          ),

          // 🔥 Indicator placed inside the image
          Positioned(
            bottom: 10.dp,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageList.length, (index) {
                bool isActive = currentIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 45.dp : 8.dp,
                  height: 8.dp,
                  decoration: BoxDecoration(
                    color: isActive
                        ? objConstantColor.orange
                        : objConstantColor.gray.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.dp),
                  ),
                );
              }),
            ),
          ),


        ],
      ),
    );
  }
}
