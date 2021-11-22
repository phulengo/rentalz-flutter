import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rentalz_flutter/services/db.dart';

class WishlistsPage extends StatefulWidget {
  WishlistsPage({Key? key}) : super(key: key);

  @override
  _WishlistsPageState createState() => _WishlistsPageState();
}

class _WishlistsPageState extends State<WishlistsPage> {
  DatabaseService db = DatabaseService();

  var liked;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Text(
              "Wishlist",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
          ]),
          const Divider(height: 32),
          user != null
              ? wishlistResult(context, user)
              : Text("Login to create your wishlist!")
        ],
      ),
    );
  }

  @override
  Widget cardGrid(BuildContext context, dynamic propertyData, User user,
      String propertyId) {
    return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.asset(
                  "assets/images/buildings/building-2.jpeg",
                )),
            const SizedBox(height: 4),
            Text(
              propertyData['propertyName'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              propertyData['propertyAddress'],
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.apartment_outlined,
                      size: 24,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(propertyData['propertyType'],
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 16)),
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 24,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                        formatDate(
                            DateTime.parse(
                                propertyData['dateAdded'].toDate().toString()),
                            [dd, '-', mm, '-', yyyy]).toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 16)),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    propertyData['propertyMonthlyPrice'],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                FutureBuilder(
                    future: db.checkUserLike(user.uid, propertyId),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState != ConnectionState.waiting) {
                        liked = snapshot.data.isNotEmpty;
                        return SizedBox(
                          width: 48,
                          child: TextButton(
                            child: Icon(
                              Icons.remove_circle_outline_outlined,
                              size: 28,
                              color: liked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text(
                                            'Do you want to remove this property from your wishlist?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Removing from wishlists"),
                                                duration:
                                                    Duration(milliseconds: 50),
                                              ));
                                              await db.removeLikeFromProperty(
                                                  user.uid, propertyId);

                                              Navigator.of(context).pop();
                                              setState(() {});
                                            },
                                            child: const Text('Yes'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('No'),
                                          ),
                                        ],
                                      ));
                            },
                          ),
                        );
                      } else {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      }
                    }),
              ],
            )
          ],
        ));
  }

  @override
  Widget wishlistResult(BuildContext context, User user) {
    _loadWishlist(userId, propertyId) async {
      var data = await db.getProperty(userId, propertyId);
      return data;
    }

    var user = Provider.of<User?>(context);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
                future: db.getAllLikedProperties(user!.uid),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  } else {
                    if (snapshot.data.isNotEmpty) {
                      var propertyIdList = snapshot.data;
                      return Container(
                        height: 600,
                        child: GridView.builder(
                            physics: ScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 700,
                                    childAspectRatio: 1.78 / 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16),
                            itemCount: propertyIdList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return FutureBuilder(
                                  future: _loadWishlist(user.uid,
                                      propertyIdList[index]['propertyId']),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator
                                              .adaptive());
                                    } else {
                                      var propertyData = snapshot.data;
                                      return cardGrid(
                                          context,
                                          propertyData,
                                          user,
                                          propertyIdList[index]['propertyId']);
                                    }
                                  });
                            }),
                      );
                    } else {
                      return const Center(child: Text("There are no results."));
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}
