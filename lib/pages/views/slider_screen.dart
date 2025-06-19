import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class SliderScreen extends StatelessWidget {
  const SliderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imageList = [
      'assets/images/slide1.jpg',
      'assets/images/slide2.jpg',
      'assets/images/slide3.jpg',
    ];

    return Column(
      children: [
        CarouselSlider(
          items: imageList.map((imagePath) {
            return Container(
              width: MediaQuery.of(context).size.width, // Ensures full width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), // Same value as parent
                child: Image.asset(
                  imagePath,
                  width: double.infinity, // Ensures full width
                  fit: BoxFit.contain, // Ensures the full image is visible
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            viewportFraction: 1, // Uses full width of the screen
            autoPlay: true, // Enables autoplay
            autoPlayInterval:
                const Duration(seconds: 3), // Changes slide every 3 seconds
            autoPlayCurve: Curves.easeInOut, // Smooth animation
            scrollPhysics: const BouncingScrollPhysics(),
          ),
        ),
      ],
    );
  }
}
