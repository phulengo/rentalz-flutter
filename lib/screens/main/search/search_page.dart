import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:rentalz_flutter/screens/main/search/search_screen.dart';
import 'package:rentalz_flutter/services/db.dart';
import 'package:date_format/date_format.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchFormKey = GlobalKey<FormBuilderState>();
  final _searchFieldController = TextEditingController();
  DatabaseService db = DatabaseService();
  var liked;

  @override
  void initState() {
    super.initState();
    // _loadSearchResult();
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
                              onTap: () async {
                                // print(propertyList[index]);
                                Navigator.pushReplacementNamed(
                                    context, '/property',
                                    arguments: {
                                      'property': propertyList[index],
                                      'propertyId':
                                          propertyId.docs[index].reference.id,
                                      'liked': liked,
                                      'des': "search-page"
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
    MediaQueryData _mediaQueryData = MediaQuery.of(context);
    var screenHeight = (_mediaQueryData.size.height * 95 / 100);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
          height: screenHeight,
          padding: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
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
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(
                                    Icons.arrow_back_ios_new_outlined),
                                color: Colors.black,
                              ),
                              hintText: 'What are you looking for?',
                              suffixIcon: _searchFieldController.text.isNotEmpty
                                  ? IconButton(
                                      icon:
                                          const Icon(Icons.backspace_outlined),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _searchFieldController.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Text(
                                      "ANYWHERE, ANYTHING",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.black),
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/home");
                                      Navigator.of(context).pushNamed("/search",
                                          arguments: {
                                            'destination': 'search-modal'
                                          });
                                    },
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      alignment: WrapAlignment.spaceBetween,
                                      children: const [
                                        Text("Check all available properties"),
                                        Icon(Icons.chevron_right_outlined)
                                      ],
                                    )),
                                const SizedBox(height: 16),
                                Row(
                                  children: const [
                                    Text(
                                      "RECENT SEARCHES",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        : searchResult(context, _searchFieldController.text),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
