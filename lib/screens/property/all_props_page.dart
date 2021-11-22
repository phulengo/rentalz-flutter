import 'package:flutter/material.dart';
import 'package:rentalz_flutter/services/db.dart';

class AllPropsPage extends StatefulWidget {
  const AllPropsPage({Key? key}) : super(key: key);

  @override
  _AllPropsPageState createState() => _AllPropsPageState();
}

class _AllPropsPageState extends State<AllPropsPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseService().getAllProperties(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator.adaptive();
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
}
