import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rentalz_flutter/services/db.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  void initState() {
    super.initState();
    final data = _loadData();
  }

  _loadData() async {
    DatabaseService db = DatabaseService();
    var propertiesList = await db.getAllProperties();
    return propertiesList;
  }

  void _handleSubmit(
      User? user, Map<String, dynamic>? formData, DateTime date) {
    FirebaseFirestore.instance
        .collection("usernames")
        .doc(user?.email)
        .set({'uid': user?.uid});
    FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("properties")
        .add({
      "propertyName": formData!['propertyName'],
      "propertyAddress": formData['propertyAddress'],
      "dateAdded": date
    });
  }

  final _formKey = GlobalKey<FormBuilderState>();

  Widget propertyList() {
    return FutureBuilder(
        future: DatabaseService().getAllProperties(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Text("None");
          } else {
            var properties = snapshot.data;
            return ListView.builder(
                shrinkWrap: true,
                itemCount: properties?.length,
                itemBuilder: (context, index) {
                  return Container(
                      child: Text(properties[index]['propertyName']));
                });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);

    final _dateAdded = DateTime.now();
    return propertyList();
    // return FormBuilder(
    //   key: _formKey,
    //   child: Column(
    //     children: [
    //       Text("UID: " + (user?.uid).toString()),
    //       Padding(
    //         padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
    //         child: FormBuilderTextField(
    //           name: 'propertyName',
    //           decoration: const InputDecoration(
    //             labelText: "Name",
    //             border: OutlineInputBorder(),
    //           ),
    //           keyboardType: TextInputType.number,
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
    //         child: FormBuilderTextField(
    //           name: 'propertyAddress',
    //           decoration: const InputDecoration(
    //             labelText: "Address",
    //             border: OutlineInputBorder(),
    //           ),
    //           keyboardType: TextInputType.number,
    //         ),
    //       ),
    //       ElevatedButton(
    //           onPressed: () {
    //             _formKey.currentState?.save();
    //             final formData = _formKey.currentState?.value;
    //             _handleSubmit(user, formData, _dateAdded);
    //           },
    //           child: const Text("Submit")),
    //       propertyList(),
    //     ],
    //   ),
    // );
  }
}
