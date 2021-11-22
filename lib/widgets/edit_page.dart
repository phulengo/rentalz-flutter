import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rentalz_flutter/services/db.dart';

class EditProperty extends StatefulWidget {
  final function;
  final propertyData;
  final propertyId;
  EditProperty(
      {Key? key,
      required this.propertyData,
      required this.propertyId,
      this.function})
      : super(key: key);

  @override
  _EditPropertyState createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
  final _editKeyForm = GlobalKey<FormBuilderState>();
  var _isFormValid = false;

  var propertyData;
  var propertyId;

  // Static data
  final _propertyTypeOptions = [
    "Apartment",
    "House",
    "Boutique hotel",
    "Bungelow",
    "Flat",
    "Unique Space",
    "Homestay"
  ];

  final _funitureTypeOptions = ["Furnished", "Unfurnished", "Part Furnished"];

  @override
  void initState() {
    super.initState();
    propertyData = widget.propertyData;
    propertyId = widget.propertyId;
  }

  _handleUpdateProperty(userId, propertyId) async {
    _editKeyForm.currentState?.save();
    final formData = _editKeyForm.currentState!.value;

    DatabaseService db = DatabaseService();
    var updateProperty = await db.updateProperty(formData, userId, propertyId);

    return updateProperty;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        children: [
          FormBuilder(
            key: _editKeyForm,
            onChanged: () {
              setState(() {
                _isFormValid = _editKeyForm.currentState!.validate();
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                children: [
                  // Basic Information
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(
                      children: [
                        Text(
                          ("Basic Information".toUpperCase()),
                          style: const TextStyle(fontWeight: FontWeight.w300),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                          child: FormBuilderTextField(
                            initialValue: propertyData['propertyName'],
                            name: 'propertyName',
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.house_outlined),
                                hintText: "Enter the name of your property",
                                labelText: "Name of property",
                                border: OutlineInputBorder()),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Property's name cannot be blank";
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.always,
                          ),
                        ),

                        // Property's address
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                          child: Column(
                            children: [
                              FormBuilderTextField(
                                name: 'propertyAddress',
                                initialValue: propertyData['propertyAddress'],
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.navigation_outlined),
                                  hintText: "Enter the adress of your property",
                                  labelText: "Location of property",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Property's location cannot be blank";
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.always,
                                keyboardType: TextInputType.streetAddress,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Detail
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(
                      children: [
                        Text(
                          ("A few more details".toUpperCase()),
                          style: const TextStyle(fontWeight: FontWeight.w300),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                            child: FormBuilderDropdown(
                              name: 'propertyType',
                              initialValue: propertyData['propertyType'],
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.apartment_outlined),
                                hintText: "Select type of your property",
                                labelText: "Type of property",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return "Property's type cannot be blank";
                                }
                                return null;
                              },
                              autovalidateMode: AutovalidateMode.always,
                              items: _propertyTypeOptions.map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                            child: FormBuilderTextField(
                              name: 'bedroomAmount',
                              initialValue: propertyData['bedroomAmount'],
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.bed_outlined),
                                hintText: "Enter number of bedrooms",
                                labelText: "Number of bedrooms",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                            child: FormBuilderDropdown(
                              name: 'furnitureType',
                              initialValue: propertyData['furnitureType'],
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.chair_outlined),
                                hintText:
                                    "Select type of your property's furniture",
                                labelText: "Type of furniture",
                                border: OutlineInputBorder(),
                              ),
                              items: _funitureTypeOptions.map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                            )),
                      ],
                    ),
                  ),
                  // Prices & Notes
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(
                      children: [
                        Text(
                          ("Prices & Notes".toUpperCase()),
                          style: const TextStyle(fontWeight: FontWeight.w300),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                          child: FormBuilderTextField(
                            name: 'propertyMonthlyPrice',
                            initialValue: propertyData['propertyMonthlyPrice'],
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.paid_outlined),
                              hintText:
                                  "Enter the monthly rent price of your property",
                              labelText: "Monthly rent price",
                              border: OutlineInputBorder(),
                              //
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Property's monthly rent price cannot be blank";
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.always,
                            inputFormatters: [
                              CurrencyTextInputFormatter(
                                locale: 'en',
                                decimalDigits: 0,
                                symbol: "\$",
                              )
                            ],
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                          child: FormBuilderTextField(
                            name: 'propertyNotes',
                            initialValue: propertyData['propertyNotes'],
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.notes_outlined),
                              hintText: "Enter notes of your property",
                              labelText: "Notes",
                              border: OutlineInputBorder(),
                              //
                            ),
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reporter
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(children: [
                      Text(
                        ("Reporter".toUpperCase()),
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                        child: FormBuilderTextField(
                          name: 'reporterName',
                          initialValue: propertyData['reporterName'],
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_outlined),
                            hintText: "Enter the name of reporter",
                            labelText: "Name of reporter",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Reporter's name cannot be blank";
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.always,
                        ),
                      ),
                    ]),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                    child: OutlinedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_isFormValid) {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title:
                                          const Text('Did you finish editing?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text('Updating Data'),
                                              duration:
                                                  Duration(milliseconds: 500),
                                            ));
                                            Navigator.pop(context);

                                            _handleUpdateProperty(
                                                propertyData['createdBy'],
                                                propertyId);
                                            Navigator.pop(context);
                                            widget.function();
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
                          } else {}
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? Colors.black
                                : Colors.grey.shade300,
                            primary: Colors.white,
                            side: BorderSide(
                                width: 0,
                                color: _isFormValid
                                    ? Colors.black
                                    : Colors.grey.shade300),
                            minimumSize: const Size(double.infinity, 60),
                            shadowColor: null)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
