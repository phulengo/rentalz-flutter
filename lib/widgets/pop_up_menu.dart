import 'package:flutter/material.dart';
import 'package:rentalz_flutter/services/db.dart';
import 'package:rentalz_flutter/widgets/modal_sheet.dart';

class PopupMenu extends StatefulWidget {
  final function;
  final refresh;
  final propertyData;
  final propertyId;

  const PopupMenu(
      {Key? key,
      required this.propertyData,
      required this.propertyId,
      this.function,
      this.refresh})
      : super(key: key);

  @override
  State<PopupMenu> createState() => _PopupMenuState();
}

_handleRemoveProperty(userId, propertyId) async {
  DatabaseService db = DatabaseService();
  var removeProperty = await db.removeProperty(userId, propertyId);
}

class _PopupMenuState extends State<PopupMenu> {
  _handleSelected(BuildContext context, dynamic value) {
    if (value == 'Edit') {
      return showModalBottomSheet(
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          context: context,
          builder: (context) {
            return ModalSheet(
                function: widget.function,
                propertyData: widget.propertyData,
                propertyId: widget.propertyId);
          });
    } else {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Are you sure to remove this property?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Deleting Data'),
                        duration: const Duration(milliseconds: 500),
                        onVisible: () {
                          _handleRemoveProperty(
                              widget.propertyData['createdBy'],
                              widget.propertyId);
                        },
                      ));

                      Navigator.pushNamedAndRemoveUntil(
                          context, "/home", (route) => false);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_horiz_outlined,
          color: Colors.white,
        ),
        onSelected: (value) {
          _handleSelected(context, value);
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry>[
            PopupMenuItem(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                value: "Edit",
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.edit_outlined),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Edit',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500))
                    ])),
            PopupMenuItem(
              padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
              value: "Delete",
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.delete_outlined,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Remove',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    )
                  ]),
            ),
          ];
        });
  }
}
