import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key}) : super(key: key);

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  // final images = [
  //   'https://img.freepik.com/free-psd/black-friday-super-sale-web-banner-template_120329-2144.jpg?size=626&ext=jpg&ga=GA1.2.2080766150.1659539596',
  //   'https://img.freepik.com/free-vector/brush-sale-sticker-black-watercolor-shopping-image-with-blank-design-space-vector_53876-154137.jpg?size=338&ext=jpg&ga=GA1.2.2080766150.1659539596',
  //   'https://img.freepik.com/premium-vector/text-effect-6_720194-6.jpg?size=626&ext=jpg&ga=GA1.2.2080766150.1659539596',
  //   'https://img.freepik.com/free-psd/black-friday-super-sale-web-banner-template_120329-2149.jpg?size=626&ext=jpg&ga=GA1.2.2080766150.1659539596'
  // ];
  List images = [];
  int activeIndex = 0;
  Future<void> getImages() async {
    var result =
        await FirebaseFirestore.instance.collection('vendorBanner').get();
    var data = result.docs;
    data.forEach((doc) {
      images.add(doc['url']);
    });
    if(mounted){
      setState((){});
    }
  }

  @override
  initState() {
    super.initState();
    getImages();
  }

  @override
  Widget build(BuildContext context) {
    return images.isEmpty
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              CarouselSlider.builder(
                  itemCount: 5,
                  options: CarouselOptions(
                    height: 230,
                    autoPlay: true,
                    // enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        activeIndex = index;
                      });
                    },
                  ),
                  itemBuilder: (ctx, index, real) {
                    final urlImage = images[index];
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          urlImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
              SizedBox(
                height: 10,
              ),
              AnimatedSmoothIndicator(
                activeIndex: activeIndex,
                count: 5,
                effect: WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                ),
              ),
            ],
          );
  }
}
