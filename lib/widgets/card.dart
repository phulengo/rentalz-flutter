import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalz_flutter/services/auth.dart';
import 'package:rentalz_flutter/services/db.dart';

class PropertyCard extends StatefulWidget {
  final BuildContext context;
  final dynamic properties;
  final int index;
  final String propertyId;
  const PropertyCard(
      {Key? key,
      required this.context,
      required this.index,
      this.properties,
      required this.propertyId})
      : super(key: key);

  @override
  _PropertyCardState createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  DatabaseService db = DatabaseService();
  AuthService auth = AuthService();
  var user;
  var liked;

  @override
  void initState() {
    super.initState();
    user = auth.getUser;
  }

  @override
  Widget build(BuildContext context) {
    // var user = Provider.of<User?>(context);

    // Destructuring
    var properties = widget.properties;
    var index = widget.index;
    var propertyId = widget.propertyId;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/property", arguments: {
          'property': properties[index],
          'propertyId': propertyId,
          'liked': liked,
          'des': 'home'
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
            Container(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            properties[index]['propertyName'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            properties[index]['propertyAddress'],
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    user != null
                        ? Row(
                            children: [
                              FutureBuilder(
                                  future:
                                      db.checkUserLike(user?.uid, propertyId),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState !=
                                        ConnectionState.waiting) {
                                      liked = snapshot.data.isNotEmpty;
                                      return SizedBox(
                                        width: 48,
                                        child: TextButton(
                                          child: Icon(
                                            liked
                                                ? Icons.favorite_outlined
                                                : Icons
                                                    .favorite_border_outlined,
                                            size: 32,
                                            color: liked
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                          onPressed: () async {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: !liked
                                                  ? Text("Adding to wishlists")
                                                  : Text(
                                                      "Removing from wishlists"),
                                              duration: Duration(seconds: 1),
                                            ));
                                            liked
                                                ? await db
                                                    .removeLikeFromProperty(
                                                        user!.uid, propertyId)
                                                : await db.addLikeToProperty(
                                                    user.uid, propertyId);
                                            setState(() {
                                              liked = !liked;
                                            });
                                          },
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator
                                              .adaptive());
                                    }
                                  }),
                              FutureBuilder(
                                  future: db.getPropertyLikesFromId(propertyId),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator
                                              .adaptive());
                                    } else {
                                      var likesAmount = snapshot.data?.length;
                                      return Text(
                                        likesAmount.toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      );
                                    }
                                  })
                            ],
                          )
                        : Container()
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
