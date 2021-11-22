import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalz_flutter/services/db.dart';
import 'package:timeago/timeago.dart' as timeago;

class LatestOffers extends StatefulWidget {
  LatestOffers({Key? key}) : super(key: key);

  @override
  _LatestOffersState createState() => _LatestOffersState();
}

class _LatestOffersState extends State<LatestOffers> {
  DatabaseService db = DatabaseService();
  var liked;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);

    return Container(
      child: Column(
        children: [
          FutureBuilder(
              future: db.getLastestPropertiesId(),
              builder: (context, AsyncSnapshot snapshot) {
                var propertyId = snapshot.data;
                return FutureBuilder(
                    future: db.getLatestProperties(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      } else {
                        var propertyList = snapshot.data;
                        if (snapshot.data.isNotEmpty) {
                          return Container(
                            height: 500,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: propertyList?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      // print(propertyList[index]);
                                      Navigator.pushReplacementNamed(
                                          context, '/property',
                                          arguments: {
                                            'property': propertyList[index],
                                            'propertyId': propertyId
                                                .docs[index].reference.id,
                                            'liked': liked,
                                            'des': 'home'
                                          });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 12, 16, 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Stack(children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(20)),
                                                  child: Image.asset(
                                                    "assets/images/buildings/building-2.jpeg",
                                                    height: 96,
                                                    width: 96,
                                                    fit: BoxFit.cover,
                                                  )),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    propertyList[index]
                                                        ['propertyName'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                      propertyList[index]
                                                          ['propertyAddress'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 12)),
                                                  const SizedBox(height: 4),
                                                  Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .apartment_outlined,
                                                          size: 16),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                          propertyList[index]
                                                              ['propertyType'],
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      12)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                      timeago
                                                          .format(DateTime.parse(
                                                              propertyList[
                                                                          index]
                                                                      [
                                                                      'dateAdded']
                                                                  .toDate()
                                                                  .toString()))
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 12))
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                          ],
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 72,
                                          child: Text(
                                              propertyList[index]
                                                  ['propertyMonthlyPrice'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 18)),
                                        ),
                                        Positioned(
                                          right: -12,
                                          top: -12,
                                          child: user != null
                                              ? FutureBuilder(
                                                  future: db.checkUserLike(
                                                    user.uid,
                                                    propertyId.docs[index]
                                                        .reference.id,
                                                  ),
                                                  builder: (context,
                                                      AsyncSnapshot snapshot) {
                                                    if (snapshot
                                                            .connectionState !=
                                                        ConnectionState
                                                            .waiting) {
                                                      liked = snapshot
                                                          .data.isNotEmpty;
                                                      return IconButton(
                                                        icon: liked
                                                            ? const Icon(Icons
                                                                .favorite_outlined)
                                                            : const Icon(Icons
                                                                .favorite_outline_outlined),
                                                        color: liked
                                                            ? Colors.red
                                                            : Colors.grey,
                                                        onPressed: () async {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: !liked
                                                                ? Text(
                                                                    "Adding to wishlists")
                                                                : Text(
                                                                    "Removing from wishlists"),
                                                            duration: Duration(
                                                                seconds: 1),
                                                          ));

                                                          liked
                                                              ? await db.removeLikeFromProperty(
                                                                  user.uid,
                                                                  propertyId
                                                                      .docs[
                                                                          index]
                                                                      .reference
                                                                      .id)
                                                              : await db.addLikeToProperty(
                                                                  user.uid,
                                                                  propertyId
                                                                      .docs[
                                                                          index]
                                                                      .reference
                                                                      .id);
                                                          setState(() {
                                                            liked = !liked;
                                                          });
                                                        },
                                                      );
                                                    } else {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator
                                                                .adaptive(),
                                                      );
                                                    }
                                                  })
                                              : Container(),
                                        ),
                                      ]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Center(
                              child: Text("There are no results."));
                        }
                      }
                    });
              })
        ],
      ),
    );
  }
}
