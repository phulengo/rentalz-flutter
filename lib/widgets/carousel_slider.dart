import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rentalz_flutter/services/db.dart';
import 'package:rentalz_flutter/widgets/card.dart';

class Carousel extends StatefulWidget {
  Carousel({Key? key}) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseService().getAllPropertiesIdByLike(),
        builder: (context, AsyncSnapshot snapshot) {
          var propertyId = snapshot.data;
          return FutureBuilder(
              future: DatabaseService().getAllPropertiesByLike(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                } else {
                  var properties = snapshot.data;
                  return CarouselSlider.builder(
                      options: CarouselOptions(
                        autoPlay: false,
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                        aspectRatio: 1.05,
                        initialPage: 0,
                        enableInfiniteScroll: false,
                        pageSnapping: false,
                      ),
                      itemCount: properties.length,
                      itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) =>
                          PropertyCard(
                            context: context,
                            index: itemIndex,
                            properties: properties,
                            propertyId: propertyId.docs[itemIndex].reference.id,
                          ));
                }
              });
        });
  }
}
