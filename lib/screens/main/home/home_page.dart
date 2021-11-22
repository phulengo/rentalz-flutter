import 'package:flutter/material.dart';
import 'package:rentalz_flutter/screens/main/home/latest_offers.dart';
import 'package:rentalz_flutter/screens/main/search/search_page.dart';
import 'package:rentalz_flutter/widgets/carousel_slider.dart';
import 'package:rentalz_flutter/widgets/logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Logo(),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 8.0),
              child: Text(
                "Find your best rental apartment",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 16.0),
          child: FocusScope(
            child: TextField(
              // enabled: false,
              showCursor: true,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                hintText: 'What are you looking for?',
              ),

              onTap: () {
                // Remove focus text field
                FocusScope.of(context).requestFocus(FocusNode());

                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return SearchPage();
                    });
              },
            ),
          ),
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: const [
          Icon(Icons.local_fire_department_outlined),
          SizedBox(width: 4),
          Text("Trending offers",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
        ]),
        Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16), child: Carousel()),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: const [
          Icon(Icons.loop_outlined),
          SizedBox(width: 4),
          Text("Latest offers",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
        ]),
        const SizedBox(height: 8),
        LatestOffers() // Limit to 5
      ],
    );
  }
}
