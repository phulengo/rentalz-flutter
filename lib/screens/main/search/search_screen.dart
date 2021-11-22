import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:rentalz_flutter/screens/main/index.dart';
import 'package:rentalz_flutter/services/db.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchScreen extends StatefulWidget {
  final destination;
  const SearchScreen({Key? key, this.destination}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchFormKey = GlobalKey<FormBuilderState>();
  final _searchFieldController = TextEditingController();
  DatabaseService db = DatabaseService();
  var liked;

  var route;

  @override
  void initState() {
    super.initState();
    route = widget.destination != null
        ? widget.destination['destination']
        : "navigation-bar";
  }

  @override
  Widget searchResult(BuildContext context, String keyWords) {
    var user = Provider.of<User?>(context);
    return FutureBuilder(
        future: db.searchAllPropertiesId(keyWords.toUpperCase()),
        builder: (context, AsyncSnapshot snapshot) {
          var propertyId = snapshot.data;
          return FutureBuilder(
              future: db.searchProperty(keyWords.toUpperCase()),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                } else {
                  var propertyList = snapshot.data;
                  if (snapshot.data.isNotEmpty) {
                    return Container(
                      height: 700,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: propertyList?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: GestureDetector(
                              onTap: () {
                                // print(propertyList[index]);
                                Navigator.pushReplacementNamed(
                                    context, '/property',
                                    arguments: {
                                      'property': propertyList[index],
                                      'propertyId':
                                          propertyId.docs[index].reference.id,
                                      'liked': liked,
                                      'des': "search-screen"
                                    });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 1),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Stack(children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.only(right: 8),
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
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                propertyList[index]
                                                    ['propertyAddress'],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12)),
                                            const SizedBox(height: 4),
                                            Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                const Icon(
                                                    Icons.apartment_outlined,
                                                    size: 16),
                                                const SizedBox(width: 2),
                                                Text(
                                                    propertyList[index]
                                                        ['propertyType'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12)),
                                                Text(" • ",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        color: Colors
                                                            .grey.shade700)),
                                                Text(
                                                    formatDate(
                                                        DateTime.parse(
                                                            propertyList[index][
                                                                    'dateAdded']
                                                                .toDate()
                                                                .toString()),
                                                        [
                                                          M,
                                                          ' ',
                                                          yy
                                                        ]).toString(),
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade700,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 12))
                                              ],
                                            ),
                                            const SizedBox(height: 8),
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
                                        style: TextStyle(
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
                                              propertyId
                                                  .docs[index].reference.id,
                                            ),
                                            builder: (context,
                                                AsyncSnapshot snapshot) {
                                              if (snapshot.connectionState !=
                                                  ConnectionState.waiting) {
                                                liked =
                                                    snapshot.data.isNotEmpty;
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
                                                        .showSnackBar(SnackBar(
                                                      content: !liked
                                                          ? Text(
                                                              "Adding to wishlists")
                                                          : Text(
                                                              "Removing from wishlists"),
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ));

                                                    liked
                                                        ? await db
                                                            .removeLikeFromProperty(
                                                                user.uid,
                                                                propertyId
                                                                    .docs[index]
                                                                    .reference
                                                                    .id)
                                                        : await db
                                                            .addLikeToProperty(
                                                                user.uid,
                                                                propertyId
                                                                    .docs[index]
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
                    return Center(child: Text("There are no results."));
                  }
                }
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);

    if (route == "search-modal") {
      return Scaffold(
          body: ListView(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
                icon: Icon(Icons.arrow_back_ios_new_outlined),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  Navigator.of(context).pop();
                }),
            Text(
              "All properties",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Visibility(
                visible: false,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_outlined),
                    onPressed: () {})),
          ]),
          const Divider(height: 32),
          Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: FutureBuilder(
                future: db.getAllPropertiesId(),
                builder: (context, AsyncSnapshot snapshot) {
                  var propertyId = snapshot.data;
                  return FutureBuilder(
                      future: db.getAllProperties(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive());
                        } else {
                          var propertyList = snapshot.data;
                          if (snapshot.data.isNotEmpty) {
                            return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
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
                                            'des': 'all-properties'
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
                                          child: FutureBuilder(
                                              future: db.checkUserLike(
                                                user!.uid,
                                                propertyId
                                                    .docs[index].reference.id,
                                              ),
                                              builder: (context,
                                                  AsyncSnapshot snapshot) {
                                                if (snapshot.connectionState !=
                                                    ConnectionState.waiting) {
                                                  liked =
                                                      snapshot.data.isNotEmpty;
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
                                                          ? await db
                                                              .removeLikeFromProperty(
                                                                  user.uid,
                                                                  propertyId
                                                                      .docs[
                                                                          index]
                                                                      .reference
                                                                      .id)
                                                          : await db
                                                              .addLikeToProperty(
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
                                              }),
                                        ),
                                      ]),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(
                                child: Text("There are no results."));
                          }
                        }
                      });
                }),
          )
        ],
      ));
    } else {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.zero,
            child: FormBuilder(
              key: _searchFormKey,
              child: FormBuilderTextField(
                  name: 'searchField',
                  onChanged: (value) {
                    setState(() {});
                  },
                  autofocus: true,
                  controller: _searchFieldController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: IconButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          Navigator.of(context).push(PageRouteBuilder(
                              opaque: true,
                              transitionDuration:
                                  const Duration(milliseconds: 200),
                              pageBuilder: (BuildContext context, _, __) {
                                return HomeScreen();
                              },
                              transitionsBuilder: (_,
                                  Animation<double> animation,
                                  __,
                                  Widget child) {
                                return SlideTransition(
                                  child: child,
                                  position: Tween<Offset>(
                                    begin: const Offset(-2.0, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                );
                              }));
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_outlined),
                        color: Colors.black,
                      ),
                      hintText: 'What are you looking for?',
                      suffixIcon: _searchFieldController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.backspace_outlined),
                              onPressed: () {
                                _searchFieldController.clear();
                              },
                            )
                          : null)),
            ),
          ),
          const Divider(
            height: 1,
          ),
          Container(
            height: 600,
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: _searchFieldController.text.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              "RECENT SEARCHES",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                : searchResult(context, _searchFieldController.text),
            // : Text("hehe"))
          )
        ],
      );
    }
  }
}
