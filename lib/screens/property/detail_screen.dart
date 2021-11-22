import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:rentalz_flutter/screens/main/index.dart';
import 'package:rentalz_flutter/services/db.dart';
import 'package:rentalz_flutter/widgets/comments.dart';
import 'package:rentalz_flutter/widgets/pop_up_menu.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetailPropertyScreen extends StatefulWidget {
  final dynamic property;
  const DetailPropertyScreen({Key? key, this.property}) : super(key: key);

  @override
  _DetailPropertyScreenState createState() => _DetailPropertyScreenState();
}

class _DetailPropertyScreenState extends State<DetailPropertyScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  DatabaseService db = DatabaseService();

  var liked;
  var property;
  var propertyId;

  _getOwnerData() async {
    var res = await db.getUserDataFromId(property['createdBy']);
    return res;
  }

  @override
  void initState() {
    super.initState();
    property = widget.property['property'];
    propertyId = widget.property['propertyId'];
    liked = widget.property['liked'];
  }

  void _onRefresh() async {
    var refreshData = await db.getProperty(property['createdBy'], propertyId);
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 10));
    setState(() {
      property = refreshData;
    });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  // void _onLoading() async {
  //   await Future.delayed(Duration(milliseconds: 10));
  //   _refreshController.loadComplete();
  // }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        controller: _refreshController,
        onRefresh: _onRefresh,
        // onLoading: _onLoading,
        child: SingleChildScrollView(
          child: Column(children: [
            Align(
              alignment: Alignment.topCenter,
              child: Stack(children: [
                Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child:
                        Image.asset("assets/images/buildings/building-2.jpeg")),
                Positioned(
                  top: 32,
                  left: 0,
                  width: 64,
                  height: 64,
                  child: InkWell(
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                      ),
                      onTap: () {
                        if (widget.property['des'] == 'home' ||
                            widget.property['des'] == 'search-screen') {
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
                        } else {
                          Navigator.pop(context);
                        }
                      }),
                ),
                Positioned(
                    right: 56,
                    top: 32,
                    height: 64,
                    child: (user != null && user.uid == property['createdBy'])
                        ? PopupMenu(
                            function: _onRefresh,
                            propertyData: property,
                            propertyId: propertyId,
                          )
                        : Container()),
                Positioned(
                  right: 24,
                  top: 32,
                  height: 64,
                  child: user != null
                      ? InkWell(
                          child: liked
                              ? const Icon(
                                  Icons.favorite_outlined,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.white,
                                ),
                          onTap: () async {
                            liked
                                ? ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                    content: !liked
                                        ? Text("Adding to wishlists")
                                        : Text("Removing from wishlists"),
                                    duration: Duration(seconds: 1),
                                  ))
                                : null;
                            liked
                                ? await db.removeLikeFromProperty(
                                    user.uid, propertyId)
                                : await db.addLikeToProperty(
                                    user.uid, propertyId);

                            setState(() {
                              liked = !liked;
                            });
                          })
                      : Container(),
                ),
              ]),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['propertyName'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(property['propertyAddress'],
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                  FutureBuilder(
                      future: db.getUserDataFromId(property['createdBy']),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          var ownerData = snapshot.data;
                          return Wrap(children: [
                            const Text("Hosted ",
                                style: TextStyle(fontSize: 12)),
                            Text(
                                timeago
                                    .format(DateTime.parse(property['dateAdded']
                                        .toDate()
                                        .toString()))
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12)),
                            const SizedBox(width: 3),
                            const Text("by ", style: TextStyle(fontSize: 12)),
                            Text(
                              ownerData['displayName'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ]);
                        } else {
                          return Container();
                        }
                      }),
                  const SizedBox(height: 16),
                  Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0)),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Row(
                        children: [
                          const Icon(Icons.paid_outlined),
                          const SizedBox(width: 16),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                property['propertyMonthlyPrice'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text("/month"),
                            ],
                          ),
                        ],
                      )),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          const Icon(Icons.apartment_outlined),
                          Text(property['propertyType'],
                              style: const TextStyle(fontSize: 16)),
                        ]),
                        Column(children: [
                          const Icon(Icons.bed_outlined),
                          Text(
                              property['bedroomAmount'] != "" &&
                                      property['bedroomAmount'] != null
                                  ? int.parse(property['bedroomAmount']) < 2
                                      ? "${property['bedroomAmount']} Bedroom"
                                      : "${property['bedroomAmount']} Bedrooms"
                                  : "0",
                              style: const TextStyle(fontSize: 16)),
                        ]),
                        Column(children: [
                          const Icon(Icons.chair_outlined),
                          Text(
                              property['furnitureType'] != null &&
                                      property['furnitureType'] != ""
                                  ? property['furnitureType']
                                  : "Not given",
                              style: const TextStyle(fontSize: 16)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.notes_outlined),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(property['propertyNotes'],
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ],
                      )),
                  const SizedBox(height: 16),
                  Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_outlined),
                          const SizedBox(width: 16),
                          Text(property['reporterName'],
                              style: const TextStyle(fontSize: 16)),
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Comments(
              ownerId: property['createdBy'],
              propertyId: propertyId,
            ),
          ]),
        ),
      )),
    );
  }
}
