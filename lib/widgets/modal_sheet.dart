import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentalz_flutter/widgets/edit_page.dart';

class ModalSheet extends StatefulWidget {
  final function;
  final propertyData;
  final propertyId;

  ModalSheet(
      {Key? key,
      required this.propertyData,
      required this.propertyId,
      this.function})
      : super(key: key);

  @override
  _ModalSheetState createState() => _ModalSheetState();
}

class _ModalSheetState extends State<ModalSheet> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData _mediaQueryData = MediaQuery.of(context);
    var screenHeight = (_mediaQueryData.size.height * 95 / 100);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
          height: screenHeight,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.close_outlined),
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              Navigator.of(context).pop();
                            }),
                        const Text(
                          "Update property information",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        Visibility(
                          visible: false,
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          child: IconButton(
                              icon: const Icon(Icons.close_outlined),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ),
                      ]),
                  const Divider()
                ],
              ),
              EditProperty(
                  function: widget.function,
                  propertyData: widget.propertyData,
                  propertyId: widget.propertyId)
            ],
          )),
    );
  }
}
